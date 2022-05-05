namespace :stats do
  desc "Send custom application metrics to Datadog"
  task track_metrics: :environment do
    Delayed::Job.where(failed_at: nil).group(:job_class).count.each do |job_class, count|
      DatadogApi.gauge('delayed_job.queued_jobs', count, tags: ["job_class:#{job_class}"])
    end

    jobs_needing_to_run_now = Delayed::Job.where(failed_at: nil).where('run_at <= ?', Time.now)
    DatadogApi.gauge('delayed_job.queue_length', jobs_needing_to_run_now.count)
    
    select_sql = Delayed::Job.sanitize_sql(["job_class, EXTRACT(epoch FROM MAX(? - run_at)) AS latency", Time.now])
    Delayed::Job.select(select_sql).where(failed_at: nil).where('run_at <= ?', Time.now).group(:job_class).as_json.each do |job_class_data|
      latency = job_class_data['latency']
      job_class = job_class_data['job_class']
      DatadogApi.gauge('delayed_job.job_latency', latency, tags: ["job_class:#{job_class}"])
    end

    EfileSubmission.state_counts.each do |state, count|
      DatadogApi.gauge('efile_submissions.state_counts', count, tags: ["current_state:#{state}"])
    end
  end

  desc "Monitor the longest periods of time that any efile submission has been in preparing, bundling, and queued"
  task monitor_delayed_efile_submissions: :environment do
    [:preparing, :bundling, :queued].each do |state|
      oldest_transition_to = EfileSubmissionTransition.where(most_recent: true, to_state: state).sort_by(&:created_at).first
      min_since_transition = ((Time.now - oldest_transition_to.created_at)/60).to_i
      DatadogApi.gauge('efile_submissions.transition_latencies_min', min_since_transition, tags: ["current_state:#{state}"])
    end
  end
end
