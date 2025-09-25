# limit to 5 requests per 15 seconds
Rack::Attack.throttle("login requests by ip", limit: 5, period: 15) do |request|
  if Flipper.enabled?(:enable_rack_attack)
    # only limit on posts to login pages
    if request.path.include?("/login") && request.post?
      request.ip
    elsif request.path.include?("/verification-code")
      request.ip
    end
  end
end
