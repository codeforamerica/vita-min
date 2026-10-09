namespace :users do
  desc "Suspends all non admin users and unassigns clients from all suspended users"
  task "suspend_non_admins" => :environment do
    User.suspend_and_unassign_clients(User.where.not(role_type: AdminRole::TYPE).or(User.suspended))
  end
end