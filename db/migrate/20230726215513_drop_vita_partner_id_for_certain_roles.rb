class DropVitaPartnerIdForCertainRoles < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      remove_column :team_member_roles, :vita_partner_id, :bigint
      remove_column :site_coordinator_roles, :vita_partner_id, :bigint
    end
  end
end
