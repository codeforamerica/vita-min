class CreateTeamMemberRolesVitaPartners < ActiveRecord::Migration[7.0]
  def change
    create_table :team_member_roles_vita_partners do |t|
      t.references :vita_partner, null: false, index: true
      t.references :team_member_role, null: false, index: true

      t.timestamps
    end
  end
end
