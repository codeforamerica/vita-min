Datadog.configure do |c|
  c.service = 'getyourrefund-app'
  c.env = Rails.env
  c.agent.host = Rails.application.credentials.dig(:datadog_agent_host)
  c.tracing.enabled = Rails.env.staging? || Rails.env.demo? || Rails.env.production?
  c.tracing.instrument :rails
  c.tracing.instrument :aws
  c.tracing.instrument :delayed_job
  c.tracing.instrument :http
end
