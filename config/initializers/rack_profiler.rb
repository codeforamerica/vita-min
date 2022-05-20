if Rails.env.demo?
  # Use the "Alt+P" keyboard shortcut to toggle visibility
  Rack::MiniProfiler.config.start_hidden = true
end
