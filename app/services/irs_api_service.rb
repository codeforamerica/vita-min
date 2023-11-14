require 'net/http'
require 'net/https'
require 'uri'
require 'jwt'
require 'nokogiri'

class IrsApiService
  def self.import_federal_data(token)
    unless ENV['USE_FAKE_API_SERVER']
      return File.read(File.join(__dir__, '..', '..', 'app', 'controllers', 'state_file', 'questions', 'df_return_sample.xml'))
    end

    # make an http request to a local fake webserver including mTLS

    certs_dir = File.join(__dir__, '..', '..', 'fake_api_server')

    if ENV['IRS_STATE_ACCOUNT_ID']
      state_prefix = ENV['IRS_STATE_ACCOUNT_ID'].start_with?('0') ? 'az' : 'ny'
      client_cert_path = File.join(certs_dir, "#{state_prefix}-cert.pem.txt")
      client_key_path = File.join(certs_dir, "#{state_prefix}-key.pem.txt")

      unless File.exist?(client_cert_path) && File.exist?(client_key_path)
        client_cert_base64_encoded = EnvironmentCredentials.dig('statefile', "#{state_prefix}_cert_base64")
        File.write(client_cert_path, Base64.decode64(client_cert_base64_encoded), mode: "wb")

        private_key_base64_encoded = EnvironmentCredentials.dig('statefile', "#{state_prefix}_private_key_base64")
        File.write(client_key_path, Base64.decode64(private_key_base64_encoded), mode: "wb")
      end


    else
      client_cert_path = File.join(certs_dir, 'client.crt')
      client_key_path = File.join(certs_dir, 'client.key')
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

    if server_url.host.include?('irs.gov') || server_url.host.include?('localhost')
      # Just cert and key are required
      http.cert = client_cert
      http.key = client_key
    elsif server_url.host.include?('cloud.gov')
      # No mTLS on this endpoint
    end

    request = Net::HTTP::Get.new(server_url.request_uri)
    request.initialize_http_header({'Authorization' => "Bearer #{token}"})

    response = http.request(request)

    unless response.header['SESSION-KEY']
      puts "Could not find key in response, bailing out..."
      puts response.body
      return
    end

    # File.write('sinatra_response.html', response.body)

    # ap({
    #      sk: Base64.decode64(response.header['SESSION-KEY']),
    #      iv: Base64.decode64(response.header['INITIALIZATION-VECTOR']),
    #      at: Base64.decode64(response.header['AUTHENTICATION-TAG']),
    #    })

    decipher = OpenSSL::Cipher.new('aes-256-gcm')
    decipher.decrypt
    decipher.key = client_key.private_decrypt(Base64.decode64(response.header['SESSION-KEY']))
    decipher.iv = Base64.decode64(response.header['INITIALIZATION-VECTOR'])
    encrypted_tax_return_bytes = Base64.decode64(JSON.parse(response.body)['taxReturn'])

    if ENV['IRS_STATE_ACCOUNT_ID']
      char_array = encrypted_tax_return_bytes.unpack("C*")
      encrypted_tax_return_bytes = char_array[0..-17].pack("C*")
      auth_tag = char_array.last(16).pack("C*")

      decipher.auth_tag = auth_tag
    else
      decipher.auth_tag = Base64.decode64(response.header['AUTHENTICATION-TAG'])
    end
    plain = decipher.update(encrypted_tax_return_bytes) + decipher.final

    # puts "Response Code: #{response.code}"
    # puts "Response Body: #{plain}"

    Nokogiri::XML(JSON.parse(plain)['xml']).to_xml
  end

  private

  def self.server_url
    if ENV['IRS_MTLS']
      URI.parse('https://df.alt.services.irs.gov/DFStateTaxReturns/1.0.0/state-api/export-return')
    elsif ENV['IRS_STATE_ACCOUNT_ID']
      URI.parse('https://state-api-staging.app.cloud.gov/state-api/export-return')
    else
      URI.parse('https://localhost:443/')
    end
  end
end
