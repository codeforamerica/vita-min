Datadog.configure do |c|
  c.service = 'getyourrefund-app'
  c.env = Rails.env
  c.tracing.instrument :rails
  c.tracing.instrument :aws
  c.tracing.instrument :delayed_job
  c.tracing.enabled = Rails.env.staging? || Rails.env.demo? || Rails.env.production?
  c.tracing hostname: Rails.application.credentials.dig(:datadog_agent_host)
end
