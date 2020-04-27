require 'webmock/rspec'

driver_urls = Webdrivers::Common.subclasses.map(&:base_url)

WebMock.disable_net_connect!(allow_localhost: true, allow: driver_urls)
