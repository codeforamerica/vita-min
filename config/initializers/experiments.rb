Rails.application.reloader.to_prepare do
  if ActiveRecord::Base.connection.table_exists?(:experiments)
    ExperimentService.ensure_experiments_exist_in_database
  end
end
