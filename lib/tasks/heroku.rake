namespace :heroku do
  desc 'Heroku release task (runs on every code push; on review app creation, runs before postdeploy task)'
  task release: :environment do
    if ActiveRecord::SchemaMigration.table_exists?
      Rake::Task['db:migrate'].invoke
    else
      Rails.logger.info "Database not initialized, skipping database migration."
    end
  end

  desc 'Heroku postdeploy task (runs once on review app creation, after release task)'
  task postdeploy: :environment do
    Rake::Task['db:schema:load'].invoke
    Rake::Task['db:seed'].invoke
  end
end
