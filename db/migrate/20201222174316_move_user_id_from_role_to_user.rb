class MoveUserIdFromRoleToUser < ActiveRecord::Migration[6.0]
  def change
    ActiveRecord::Base.connection.execute(
      "UPDATE users SET role_id=organization_lead_roles.id, role_type='OrganizationLeadRole' FROM organization_lead_roles WHERE organization_lead_roles.user_id=users.id"
    )
    remove_column :organization_lead_roles, :user_id
  end
end
