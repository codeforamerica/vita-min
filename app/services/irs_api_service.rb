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
    client_cert_path = File.join(certs_dir, 'client.crt')
    client_key_path = File.join(certs_dir, 'client.key')
    server_ca_cert_path = File.join(certs_dir, 'ca.crt')

    server_url = URI.parse('https://localhost:443/')

    client_cert = OpenSSL::X509::Certificate.new(File.read(client_cert_path))
    client_key = OpenSSL::PKey::RSA.new(File.read(client_key_path))

    claim = {
      "iss": "MD_ID", # State identifier provided by the IRS
      "iat": Time.now.to_i, # Issued at time
      "nonce": SecureRandom.hex(8), # In combination with iat, verify this is a unique transaction :secrets.token_hex(8)
      "sub": "cool_auth_code", # User authorization code from Direct File
    }

    puts claim

    token = JWT.encode claim, client_key, 'RS256'

    puts token
    # verifying that JWT was actually sent
    decoded_token = JWT.decode token, client_cert.public_key, true, { algorithm: 'RS256' }

    puts decoded_token

    http = Net::HTTP.new(server_url.host, server_url.port)
    http.use_ssl = true
    http.cert = client_cert
    http.key = client_key
    # In most cases, we can omit this as the signing CA cert is already in the system's trust store.
    # However, since we are self-signing and it currently isn't in the trust store we need to provide it.
    http.ca_file = server_ca_cert_path

    request = Net::HTTP::Get.new(server_url.request_uri)
    request.initialize_http_header({'Authorization' => "Bearer #{token}"})

    response = http.request(request)

    decipher = OpenSSL::Cipher.new('aes-256-gcm')
    decipher.decrypt
    decipher.key = client_key.private_decrypt(Base64.decode64(response.header['SESSION-KEY']))
    decipher.iv = Base64.decode64(response.header['INITIALIZATION-VECTOR'])
    decipher.auth_tag = Base64.decode64(response.header['AUTHENTICATION-TAG'])
    plain = decipher.update(Base64.decode64(response.body)) + decipher.final

    puts "Response Code: #{response.code}"
    puts "Response Body: #{plain}"
    # File.write('sinatra_response.html', response.body)

    plain
  end
end


class JsonWebToken # todo : move class to its own file
  def self.encode(payload, exp = 15.min.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, Rails.application.secrets.secret_key_base.to_s)
  end

  def auth_header
    # { Authorization: 'Bearer <token>' }
    request.headers['Authorization']
  end

  def self.decode(token)
    decoded = JWT.decode(token, Rails.application.secrets.secret_key_base.to_s)[0]
    HashWithIndifferentAccess.new decoded
  end
end