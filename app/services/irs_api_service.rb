require 'net/http'
require 'net/https'
require 'uri'
require 'jwt'
class IrsApiService
  def self.import_federal_data(token)
    unless ENV['USE_FAKE_API_SERVER']
      return File.read(File.join(__dir__, '..', '..', 'app', 'controllers', 'state_file', 'questions', 'df_return_sample.xml'))
    end

    # make an http request to a local fake webserver including mTLS

    certs_dir =  File.join(__dir__, '..', '..', 'fake_api_server')

    if ENV['IRS_STATE_ACCOUNT_ID']
      client_cert_path = File.join(certs_dir, 'az-cert.pem.txt')
      client_key_path = File.join(certs_dir, 'az-key.pem.txt')
    else
      client_cert_path = File.join(certs_dir, 'client.crt')
      client_key_path = File.join(certs_dir, 'client.key')
    end
    server_ca_cert_path = File.join(certs_dir, 'ca.crt')


    if ENV['IRS_STATE_ACCOUNT_ID']
      server_url = URI.parse('https://state-api-staging.app.cloud.gov/state-api/export-return')
    else
      server_url = URI.parse('https://localhost:443/')
    end

    client_cert = OpenSSL::X509::Certificate.new(File.read(client_cert_path))
    client_key = OpenSSL::PKey::RSA.new(File.read(client_key_path))

    claim = {
      "iss": ENV['IRS_STATE_ACCOUNT_ID'] || 'abcdef', # State identifier provided by the IRS
      "iat": Time.now.to_i, # Issued at time
      "sub": token, # User authorization code from Direct File
    }

    token = JWT.encode claim, client_key, 'RS256'

    # puts token
    # # verifying that JWT was actually sent
    # decoded_token = JWT.decode token, client_cert.public_key, true, { algorithm: 'RS256' }
    #
    # puts decoded_token

    http = Net::HTTP.new(server_url.host, server_url.port)
    http.use_ssl = true
    unless ENV['IRS_STATE_ACCOUNT_ID']
      http.cert = client_cert
      http.key = client_key
      # In most cases, we can omit this as the signing CA cert is already in the system's trust store.
      # However, since we are self-signing and it currently isn't in the trust store we need to provide it.
      http.ca_file = server_ca_cert_path
    end

    request = Net::HTTP::Get.new(server_url.request_uri)
    request.initialize_http_header({'Authorization' => "Bearer #{token}"})

    response = http.request(request)

    unless response.header['SESSION-KEY']
      puts "Could not find key in response, bailing out..."
      return
    end

    # ap({
    #      sk: Base64.decode64(response.header['SESSION-KEY']),
    #      iv: Base64.decode64(response.header['INITIALIZATION-VECTOR']),
    #      at: Base64.decode64(response.header['AUTHENTICATION-TAG']),
    #    })

    decipher = OpenSSL::Cipher.new('aes-256-gcm')
    decipher.decrypt
    decipher.key = client_key.private_decrypt(Base64.decode64(response.header['SESSION-KEY']))
    decipher.iv = Base64.decode64(response.header['INITIALIZATION-VECTOR'])
    decipher.auth_tag = Base64.decode64(response.header['AUTHENTICATION-TAG'])
    plain = decipher.update(Base64.decode64(JSON.parse(response.body)['taxReturn'])) + decipher.final

    # puts "Response Code: #{response.code}"
    # puts "Response Body: #{plain}"
    # File.write('sinatra_response.html', response.body)

    plain
  end
end
