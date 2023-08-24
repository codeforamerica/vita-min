Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.max_attempts = 1

module Delayed
  module Plugins
    class AddExtraJobAttributes < Plugin
      callbacks do |lifecycle|
        lifecycle.before(:enqueue) do |delayed_job|
          serialized_job = delayed_job.payload_object.job_data
          delayed_job.assign_attributes(
            job_class: serialized_job['job_class'],
            job_object_id: serialized_job['job_object_id'],
            active_job_id: serialized_job['job_id']
          )
        end
      end
    end
  end
end

Delayed::Worker.plugins << Delayed::Plugins::AddExtraJobAttributes

class CanAccessDelayedJobWeb
  def self.matches?(request)
    return true if Rails.env.development? || Rails.env.heroku?

    current_user = request.env['warden'].user
    current_user.present? && current_user.admin? && current_user.role.engineer?
  end
end
