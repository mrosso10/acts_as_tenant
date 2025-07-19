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

      job_id = job_data["job_id"]
      job_class = job_data["job_class"]
      if tenant_unscoped
        Rails.logger.tagged(job_class, job_id).warn "WARN: Running job with ActsAsTenant unscoped. Admin?"
        ActsAsTenant.unscoped = true
      else
        if tenant_global_id
          Rails.logger.tagged(job_class, job_id).info "Running job with tenant: #{tenant_global_id}"
          ActsAsTenant.current_tenant = GlobalID::Locator.locate(tenant_global_id)
        else
          ActsAsTenant.current_tenant = nil
        end
      end

      super
    end
  end
end
