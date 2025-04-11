if Rails.env.heroku? || Rails.env.demo? || Rails.env.production?
  # Use the "Alt+P" keyboard shortcut to toggle visibility
  Rack::MiniProfiler.config.start_hidden = true
end

if ENV['REDIS_URL'].present?
  Rack::MiniProfiler.config.storage_options = { url: ENV["REDIS_URL"] }
  Rack::MiniProfiler.config.storage = Rack::MiniProfiler::RedisStore
end