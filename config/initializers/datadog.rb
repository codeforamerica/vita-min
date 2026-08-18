Rails.application.config.to_prepare do
  Datadog.configure do |c|
    c.service = 'getyourrefund-app'
    c.env = Rails.env
    c.agent.host = EnvironmentCredentials['DATADOG_AGENT_HOST']
    enable_tracing = Rails.env.staging? || Rails.env.demo? || Rails.env.production?
    c.tracing.enabled = enable_tracing
    if enable_tracing
      c.use :rails
      c.use :aws
      c.use :delayed_job
      c.use :http
    end
  end
end
