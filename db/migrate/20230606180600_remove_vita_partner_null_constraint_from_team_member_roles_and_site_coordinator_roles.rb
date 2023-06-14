class RemoveVitaPartnerNullConstraintFromTeamMemberRolesAndSiteCoordinatorRoles < ActiveRecord::Migration[7.0]
  def change
    change_column_null(:team_member_roles, :vita_partner_id, true)
    change_column_null(:site_coordinator_roles, :vita_partner_id, true)
  end
end
