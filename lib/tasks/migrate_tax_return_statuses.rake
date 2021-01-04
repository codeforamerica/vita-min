namespace :db do
  desc 'migrates old tax return statuses to updated statuses'
  task update_tax_return_statuses: [:environment] do
    MigrateStatuses.migrate_all
  end
end