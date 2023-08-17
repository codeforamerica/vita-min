namespace :worker_heartbeat do
  desc 'Enqueue jobs to track queue delays'
  task enqueue: :environment do
    WorkerHeartbeatJob.perform_now(Time.current.to_i)
  end
end