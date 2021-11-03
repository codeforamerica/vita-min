namespace :stats do
  desc "Send custom application metrics to Datadog"
  task track_metrics: :environment do
    DatadogApi.gauge('delayed_job.queue_length', Delayed::Job.where(failed_at: nil).where('run_at <= ?', Time.now).count)
    EfileSubmission.state_counts.each do |state, count|
      DatadogApi.gauge('efile_submissions.state_counts', count, tags: ["current_state:#{state}"])
    end
  end
end
