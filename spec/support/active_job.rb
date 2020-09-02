RSpec.configure do |config|
  config.include ActiveJob::TestHelper, active_job: true

  config.before(:each) do |example|
    next if example.metadata[:type] != :job || example.metadata[:active_job].blank?
    # Disable the rescue_handlers added by the job's retry_on,
    # so that errors bubble up as if this is the last attempt for the job.
    allow(ZendeskJob).to receive(:rescue_handlers).and_return([])
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
