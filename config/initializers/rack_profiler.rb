if Rails.env.demo? || Rails.env.heroku? || Rails.env.staging?
  # Use the "Alt+P" keyboard shortcut to toggle visibility
  Rack::MiniProfiler.config.start_hidden = true
end
