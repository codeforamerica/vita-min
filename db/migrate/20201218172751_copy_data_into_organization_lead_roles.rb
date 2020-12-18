class CopyDataIntoOrganizationLeadRoles < ActiveRecord::Migration[6.0]
  def up
    execute "insert into organization_lead_roles (user_id, vita_partner_id, created_at, updated_at)
             select id as user_id, vita_partner_id, now(), now()
             from users
             where users.vita_partner_id is not null and not users.is_admin;"
  end

  def down
    execute "truncate organization_lead_roles;"
  end
end
