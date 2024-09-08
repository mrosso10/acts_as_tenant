class TenantableTask < ActiveRecord::Base
  acts_as_tenant :account

  tenantable_belongs_to :project, assign_tenant_from_associated: true
  default_scope -> { where(completed: nil).order("name") }

  validates_uniqueness_of :name
end
