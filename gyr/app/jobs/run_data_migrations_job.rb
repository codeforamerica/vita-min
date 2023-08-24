class RunDataMigrationsJob < ApplicationJob
  def perform
    DataMigrate::Tasks::DataMigrateTasks.migrate
  end

  def priority
    PRIORITY_LOW
  end
end