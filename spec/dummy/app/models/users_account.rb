class UsersAccount < ActiveRecord::Base
  belongs_to :user, inverse_of: :users_accounts
  acts_as_tenant :account
end
