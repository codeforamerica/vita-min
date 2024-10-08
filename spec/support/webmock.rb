require 'webmock/rspec'

if ENV['DOCKER']
  WebMock.allow_net_connect!
else
  WebMock.disable_net_connect!(allow_localhost: true)
end