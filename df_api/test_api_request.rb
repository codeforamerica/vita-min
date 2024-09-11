#!/usr/bin/env ruby

require_relative '../app/services/irs_api_service'

if ARGV.length < 2
  puts "please provide token and state code"
  return
end

if IrsApiService.server_url
  puts "Testing against API URL #{IrsApiService.server_url}"
else
  puts "Please set an ENV variable such that IrsApiService.server_url returns something!"
  exit 1
end

puts IrsApiService.import_federal_data(ARGV[0], ARGV[1])
