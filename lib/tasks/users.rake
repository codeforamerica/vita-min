namespace :users do
  desc "Suspends all non admin users"
  task "suspend_non_admins" => :environment do
    User.where(suspended_at: nil).where.not(role_type: AdminRole::TYPE).update_all(suspended_at: DateTime.now)
  end
end