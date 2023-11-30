module Hub
  class DataMigrationsController < Hub::BaseController
    before_action :require_engineer
    layout "hub"

    def index
      @existing_job = Delayed::Job.find_by(job_class: RunDataMigrationsJob.name)
    end

    def migrate
      RunDataMigrationsJob.perform_later

      redirect_to action: :index
    end
  end
end