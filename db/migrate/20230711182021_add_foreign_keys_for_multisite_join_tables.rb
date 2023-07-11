class AddForeignKeysForMultisiteJoinTables < ActiveRecord::Migration[7.0]
  def change
    safety_assured do # There aren't all that many of these join table entries yet, locking shouldn't be a concern.
      add_foreign_key "site_coordinator_roles_vita_partners", "site_coordinator_roles"
      add_foreign_key "site_coordinator_roles_vita_partners", "vita_partners"
      add_foreign_key "team_member_roles_vita_partners", "team_member_roles"
      add_foreign_key "team_member_roles_vita_partners", "vita_partners"
    end
  end
end
