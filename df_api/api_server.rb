#!/usr/bin/env ruby

require 'sinatra'
require 'nokogiri'
require 'jwt'
require 'json'

set :port, 9494

get '/' do
  certs_dir =  File.join(__dir__)
  client_cert_path = File.join(certs_dir, 'client.crt')
  client_cert = OpenSSL::X509::Certificate.new(File.read(client_cert_path))

  token = request.env['HTTP_AUTHORIZATION'].split(' ')[1]
  decoded_token = JWT.decode token, client_cert.public_key, true, { algorithm: 'RS256' }
  puts "Decoded token on server: #{decoded_token}"

  xml_content = File.read(File.join(__dir__, '..', 'app', 'controllers', 'state_file', 'questions', 'df_return_sample.xml'))
  xml = Nokogiri::XML(xml_content)
  xml.at('AddressLine1Txt').content = '123 Api Test'
  plaintext_response = {status: 'accepted', xml: xml.to_s}.to_json

  cipher = OpenSSL::Cipher.new('aes-256-gcm')
  cipher.encrypt
  key = cipher.random_key
  iv = cipher.random_iv

  encrypted = cipher.update(plaintext_response) + cipher.final
  tag = cipher.auth_tag # produces 16 bytes tag by default

  headers['SESSION-KEY'] = Base64.encode64(client_cert.public_key.public_encrypt(key))
  headers['INITIALIZATION-VECTOR'] = Base64.encode64(iv)
  headers['AUTHENTICATION-TAG'] = Base64.encode64(tag)

  {
    status: 'success',
    taxReturn: Base64.encode64(encrypted)
  }.to_json
end
