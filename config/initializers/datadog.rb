# APM
Datadog.configure do |c|
  c.service = 'getyourrefund-app'
  c.env = Rails.env
  c.use :rails
  c.use :aws
  c.use :sequel
  c.use :delayed_job
  c.tracer.enabled = Rails.env.staging? || Rails.env.development?
  c.tracer hostname: Rails.application.credentials.dig(Rails.env.to_sym, :datadog_agent_host)
end

# DogStatsD
DatadogMetrics.configure do |c|
  c.enabled = Rails.env.staging? || Rails.env.development?
  c.host = 'localhost'
  c.port = 8125
  c.namespace = 'dogstatsd'
end
