# frozen_string_literal: true

class CreateJoinTableRowsForSingleSiteRoles < ActiveRecord::Migration[7.0]
  def up
    ActiveRecord::Base.transaction do
      roles_to_join_tables = {
        SiteCoordinatorRole => {
          join_table_class: SiteCoordinatorRolesVitaPartner,
          fk: :site_coordinator_role_id
        },
        TeamMemberRole => {
          join_table_class: TeamMemberRolesVitaPartner,
          fk: :team_member_role_id
        },
      }
      roles_to_join_tables.each do |role_class, data|
        join_table_attributes = role_class.where.not(legacy_vita_partner: nil).map do |role|
          { data[:fk] => role.id, vita_partner_id: role.legacy_vita_partner.id }
        end
        data[:join_table_class].upsert_all(join_table_attributes)

        role_class.update_all(vita_partner_id: nil)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
