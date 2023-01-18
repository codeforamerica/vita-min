class RunDataMigrationsJob < ApplicationJob
  def perform
    DataMigrate::Tasks::DataMigrateTasks.migrate
  end
end