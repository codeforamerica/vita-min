Datadog.configure do |c|
  c.service = 'getyourrefund-app'
  c.env = Rails.env
  c.agent.host = Rails.application.credentials.dig(:datadog_agent_host)
  enable_tracing = Rails.env.staging? || Rails.env.demo? || Rails.env.production?
  c.tracing.enabled = enable_tracing
  if enable_tracing
    c.tracing.use :rails
    c.tracing.use :aws
    c.tracing.use :delayed_job
    c.tracing.use :http
  end
end
