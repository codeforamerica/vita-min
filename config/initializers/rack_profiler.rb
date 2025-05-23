if Rails.env.heroku? || Rails.env.demo?
  # Use the "Alt+P" keyboard shortcut to toggle visibility
  Rack::MiniProfiler.config.start_hidden = true
end

if ENV['REDIS_URL'].present? && (Rails.env.demo? || Rails.env.development? || Rails.env.heroku? || Rails.env.staging?)
  Rack::MiniProfiler.config.storage_options = { url: ENV["REDIS_URL"] }
  Rack::MiniProfiler.config.storage = Rack::MiniProfiler::RedisStore
end