require 'openssl'
require 'net/http'

# based on https://smallstep.com/hello-mtls/doc/client/ruby
client_cert = OpenSSL::X509::Certificate.new(File.read('/tmp/cert.pem'))

options = {
  use_ssl: true,
  verify_mode: OpenSSL::SSL::VERIFY_PEER,
  cert: client_cert,
  key: OpenSSL::PKey::RSA.new(File.read('/tmp/key.pem')),
}

# Client certificate test site found via
# https://stackoverflow.com/questions/56798331/are-there-any-public-web-services-that-will-check-for-an-mtls-cert-and-response
http = Net::HTTP.start('certauth.idrix.fr', 443, options)

response = http.request(Net::HTTP::Get.new('/json/'))
puts "****************************"
puts response.body
  
