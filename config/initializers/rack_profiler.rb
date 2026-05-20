if defined?(Rack::MiniProfiler)
  Rack::MiniProfiler.config.start_hidden = true if Rails.env.demo?
  Rack::MiniProfiler.config.toggle_shortcut = 'CTRL+Y'

  if ENV['REDIS_URL'].present? && (Rails.env.demo? || Rails.env.development? || Rails.env.heroku? || Rails.env.staging?)
    Rack::MiniProfiler.config.storage_options = { url: ENV["REDIS_URL"] }
    Rack::MiniProfiler.config.storage = Rack::MiniProfiler::RedisStore
  end
end
