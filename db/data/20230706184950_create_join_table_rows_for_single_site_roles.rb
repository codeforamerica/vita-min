# frozen_string_literal: true

class CreateJoinTableRowsForSingleSiteRoles < ActiveRecord::Migration[7.0]
  def up
    ActiveRecord::Base.transaction do
      roles_to_join_tables = {
        SiteCoordinatorRole => {
          join_table_class: SiteCoordinatorRolesVitaPartner,
          fk: :site_coordinator_role
        },
        TeamMemberRole => {
          join_table_class: TeamMemberRolesVitaPartner,
          fk: :team_member_role
        },
      }
      roles_to_join_tables.each do |role_class, data|
        role_class.where.not(legacy_vita_partner: nil).each do |role|
          jt = data[:join_table_class].find_or_create_by!(
            data[:fk] => role,
            vita_partner: role.legacy_vita_partner
          )
        end
        role_class.update_all(vita_partner_id: nil)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
