if Rails.env.heroku? || Rails.env.demo? || Rails.env.production?
  # Use the "Alt+P" keyboard shortcut to toggle visibility
  Rack::MiniProfiler.config.start_hidden = true
end
