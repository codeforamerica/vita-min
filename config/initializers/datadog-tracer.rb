Datadog.configure do |c|
  c.service = 'getyourrefund-app'
  c.env = Rails.env
  c.use :rails
  c.use :aws
  c.use :sequel
  c.use :delayed_job
  c.tracer.enabled = Rails.env.staging? || Rails.env.demo? || Rails.env.production?
  c.tracer hostname: Rails.application.credentials.dig(Rails.env.to_sym, :datadog_agent_host)
end