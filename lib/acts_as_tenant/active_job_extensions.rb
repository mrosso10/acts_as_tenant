module ActsAsTenant
  module ActiveJobExtensions
    def serialize
      super.merge(
        "current_tenant" => ActsAsTenant.current_tenant&.to_global_id&.to_s,
        "tenant_unscoped" => ActsAsTenant.unscoped?
      )
    end

    def deserialize(job_data)
      tenant_global_id = job_data.delete("current_tenant")
      tenant_unscoped = job_data.delete("tenant_unscoped")

      if tenant_unscoped
        # FIXME: include job data
        Rails.logger.warn "WARN: Running job with ActsAsTenant unscoped. Admin?"
        ActsAsTenant.unscoped = true
      else
        ActsAsTenant.current_tenant = tenant_global_id ? GlobalID::Locator.locate(tenant_global_id) : nil
      end

      super
    end
  end
end
