# limit to 5 requests per second
Rack::Attack.throttle("login requests by ip", limit: 5, period: 15) do |request|
  # only limit on posts to login pages
  if request.path.include?("/login") && request.post?
    request.ip
  elsif request.path.include?("/verification-code")
    request.ip
  end
end
