namespace :stats do
  desc "Send custom application metrics to Datadog"
  task track_metrics: :environment do
    Delayed::Job.where(failed_at: nil).group(:job_class).count.each do |job_class, count|
      DatadogApi.gauge('delayed_job.queued_jobs', count, tags: ["job_class:#{job_class}"])
    end

    jobs_needing_to_run_now = Delayed::Job.where(failed_at: nil).where('run_at <= ?', Time.now)
    DatadogApi.gauge('delayed_job.queue_length', jobs_needing_to_run_now.count)
    
    select_sql = Delayed::Job.sanitize_sql(["job_class, MAX(? - run_at) AS latency", Time.now])
    Delayed::Job.select(select_sql).where(failed_at: nil).where('run_at <= ?', Time.now).group(:job_class).as_json.each do |job_class_data|
      latency = job_class_data['latency']
      job_class = job_class_data['job_class']
      DatadogApi.gauge('delayed_job.job_latency', latency, tags: ["job_class:#{job_class}"])
    end

    EfileSubmission.state_counts.each do |state, count|
      DatadogApi.gauge('efile_submissions.state_counts', count, tags: ["current_state:#{state}"])
    end
  end
end
