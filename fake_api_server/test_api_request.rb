#!/usr/bin/env ruby

require_relative '../app/services/irs_api_service'

ENV['USE_FAKE_API_SERVER'] = 'true'
puts IrsApiService.import_federal_data('abcde')
