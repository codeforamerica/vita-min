namespace :cleanup_orphaned_users do
  desc 'Remove users that do not have a role'
  task find_orphaned_users: [:environment] do
    admin_orphaned_users = User.joins("LEFT JOIN admin_roles ON users.role_id = admin_roles.id AND users.role_type = 'AdminRole'")
                               .where(admin_roles: { id: nil }, role_type: 'AdminRole')

    greeter_orphaned_users = User.joins("LEFT JOIN greeter_roles ON users.role_id = greeter_roles.id AND users.role_type = 'GreeterRole'")
                                 .where(greeter_roles: { id: nil }, role_type: 'GreeterRole')

    site_coordinator_orphaned_users = User.joins("LEFT JOIN site_coordinator_roles ON users.role_id = site_coordinator_roles.id AND users.role_type = 'SiteCoordinatorRole'")
                                     .where(site_coordinator_roles: { id: nil }, role_type: 'SiteCoordinatorRole')

    client_success_orphaned_users = User.joins("LEFT JOIN client_success_roles ON users.role_id = client_success_roles.id AND users.role_type = 'ClientSuccessRole'")
                               .where(client_success_roles: { id: nil }, role_type: 'ClientSuccessRole')

    coalition_lead_orphaned_users = User.joins("LEFT JOIN coalition_lead_roles ON users.role_id = coalition_lead_roles.id AND users.role_type = 'CoalitionLeadRole'")
                               .where(coalition_lead_roles: { id: nil }, role_type: 'CoalitionLeadRole')

    organization_lead_orphaned_users = User.joins("LEFT JOIN organization_lead_roles ON users.role_id = organization_lead_roles.id AND users.role_type = 'OrganizationLeadRole'")
                                        .where(organization_lead_roles: { id: nil }, role_type: 'OrganizationLeadRole')

    team_member_orphaned_users = User.joins("LEFT JOIN team_member_roles ON users.role_id = team_member_roles.id AND users.role_type = 'TeamMemberRole'")
                                        .where(team_member_roles: { id: nil }, role_type: 'TeamMemberRole')

    orphaned_users = admin_orphaned_users + greeter_orphaned_users + site_coordinator_orphaned_users + client_success_orphaned_users + coalition_lead_orphaned_users + organization_lead_orphaned_users + team_member_orphaned_users

    puts "These users have no roles: #{orphaned_users.pluck(:id)}"
  end

  desc "Replace user_id calls in other models and delete old user"
  task :replace_user_associations_and_delete_old_user, [:old_user_id, :new_user_id] => :environment do |t, args|
    old_user_id = args[:old_user_id]
    new_user_id = args[:new_user_id]
    if old_user_id.nil? || new_user_id.nil?
      puts "Please provide a user ID."
      next
    end

    old_user = User.find_by(id: old_user_id)
    new_user = User.find_by(id: new_user_id)

    if old_user.nil? || new_user.nil?
      puts "Please provide users that exist"
    else
      if old_user.role.present?
        puts "Role for old user ##{old_user_id} is present, are you sure you want to delete?"
        next
      end

      logs = AccessLog.where(user: old_user)
      logs.update(user: new_user)

      notes = Note.where(user_id: old_user)
      notes.update(user: new_user)

      notifications = UserNotification.where(user_id: old_user)
      notifications.update(user: new_user)

      system_notes = SystemNote.where(user_id: old_user)
      system_notes.update(user: new_user)

      puts "User with ID #{old_user_id} and associated records have been replaced with ID #{new_user_id}."

      old_user.destroy!

      puts "User with ID #{old_user_id} has been deleted"
    end
  end
end