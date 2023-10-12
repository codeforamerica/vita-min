#!/usr/bin/env ruby

require 'sinatra'
require 'nokogiri'

set :port, 9494

get '/' do
  xml_content = File.read(File.join(__dir__, '..', 'app', 'controllers', 'state_file', 'questions', 'df_return_sample.xml'))
  xml = Nokogiri::XML(xml_content)
  xml.at('AddressLine1Txt').content = '123 Api Test'
  xml.to_s
end
