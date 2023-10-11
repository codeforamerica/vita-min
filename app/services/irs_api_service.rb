require 'net/http'
require 'net/https'
require 'uri'
class IrsApiService
  def self.import_federal_data(token)
    unless ENV['USE_FAKE_API_SERVER']
      return File.read(File.join(__dir__, '..', '..', 'app', 'controllers', 'state_file', 'questions', 'df_return_sample.xml'))
    end

    # make an http request to a local fake webserver including mTLS
    # TODO: there will be a JWT in there with some details about what we want to access, also encrypted
    # TODO: the result we get will have to be decrypted

    client_cert_path = './client.crt'
    client_key_path = './client.key'
    server_ca_cert_path = './ca.crt'

    server_url = URI.parse('https://localhost:443/')

    client_cert = OpenSSL::X509::Certificate.new(File.read(client_cert_path))
    client_key = OpenSSL::PKey::RSA.new(File.read(client_key_path))

    http = Net::HTTP.new(server_url.host, server_url.port)
    http.use_ssl = true
    http.cert = client_cert
    http.key = client_key
    # In most cases, we can omit this as the signing CA cert is already in the system's trust store.
    # However, since we are self-signing and it currently isn't in the trust store we need to provide it.
    http.ca_file = server_ca_cert_path

    request = Net::HTTP::Get.new(server_url.request_uri)
    response = http.request(request)

    puts "Response Code: #{response.code}"
    puts "Response Body: #{response.body}"
  end
end