if Rails.env.test?
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
else
  # is this even a thing lol
  Rack::Attack.cache.store = Rack::MiniProfiler::RedisStore
end

# limit to 5 requests per second
Rack::Attack.throttle("login requests by ip", limit: 5, period: 1) do |request|
  # only limit on posts to login pages
  if request.path.include?("/login") && request.post?
    # limit by IP
    request.ip
  end
end
