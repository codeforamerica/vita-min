RSpec.configure do |config|
  config.include ActiveJob::TestHelper, active_job: true

  config.before(:each) do |example|
    next if example.metadata[:type] != :job || example.metadata[:active_job].blank?
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
