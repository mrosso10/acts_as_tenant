require "spec_helper"

class DomainController < ActionController::Base
  include Rails.application.routes.url_helpers
  set_current_tenant_by_subdomain_or_domain
end

describe DomainController, type: :controller do
  let(:account) { accounts(:with_domain) }

  controller do
    def index
      # Exercise current_tenant helper method
      render plain: current_tenant.name
    end
  end

  it "finds the correct tenant with a example1.com" do
    @request.host = account.domain
    get :index
    expect(ActsAsTenant.current_tenant).to eq account
    expect(response.body).to eq account.name
  end

  it "finds the correct tenant with a subdomain.example.com" do
    @request.host = "#{account.subdomain}.example.com"
    get :index
    expect(ActsAsTenant.current_tenant).to eq account
    expect(response.body).to eq account.name
  end

  it "finds the correct tenant with a www.subdomain.example.com" do
    @request.host = "www.#{account.subdomain}.example.com"
    get :index
    expect(ActsAsTenant.current_tenant).to eq account
  end

  it "ignores case when finding tenant by subdomain" do
    @request.host = "#{account.subdomain.upcase}.example.com"
    get :index
    expect(ActsAsTenant.current_tenant).to eq account
  end

  context "overriding subdomain lookup" do
    after { controller.subdomain_lookup = :last }

    it "allows overriding the subdomain lookup" do
      controller.subdomain_lookup = :first
      @request.host = "#{account.subdomain}.another.example.com"
      get :index
      expect(ActsAsTenant.current_tenant).to eq account
      expect(response.body).to eq(account.subdomain)
    end
  end

  context 'when there is no domain' do
    controller do
      def index
        head :ok
      end
    end

    it 'passes' do
      @request.host = '127.0.0.1'
      get :index
      expect(response).to have_http_status(:ok)
    end
  end
end
