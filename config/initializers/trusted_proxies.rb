# These need to happen after initialization because classes haven't been loaded yet
Rails.application.server do
  Rails.application.configure do
    puts "HELLO I AM RAILS.APPLICATION.SERVER"
    ConfigureTrustedProxiesJob.perform_now(current_or_cached: :cached)
    ConfigureTrustedProxiesJob.perform_later(current_or_cached: :current)
  end
end
