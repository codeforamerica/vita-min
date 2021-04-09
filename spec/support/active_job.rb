RSpec.configure do |config|
  config.include ActiveJob::TestHelper, active_job: true
  config.include ActiveJob::TestHelper, type: :job
  config.include ActiveJob::TestHelper, type: :feature

  config.before(:each) do |example|
    if [:job, :feature].include? example.metadata[:type] || example.metadata[:active_job]
      clear_enqueued_jobs
      clear_performed_jobs
    end
  end
end
