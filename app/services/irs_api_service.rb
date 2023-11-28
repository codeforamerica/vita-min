require 'net/http'
require 'net/https'
require 'uri'
require 'jwt'
require 'nokogiri'

class IrsApiService
  def self.df_return_sample
    File.read(File.join(__dir__, '..', '..', 'app', 'controllers', 'state_file', 'questions', 'df_return_sample.xml'))
  end

  def self.import_federal_data(authorization_code, state_code)
    if authorization_code == "abcdefg"
      return df_return_sample
    end

    account_id = EnvironmentCredentials.dig('statefile', state_code, "account_id")
    cert_finder = CertificateFinder.new(server_url, state_code)

    claim = {
      "iss": account_id.to_s, # State identifier provided by the IRS
      "iat": Time.now.to_i, # Issued at time
      "sub": authorization_code, # User authorization code from Direct File
    }

    token = JWT.encode claim, cert_finder.client_key, 'RS256'
    # puts token
    # # verifying that JWT was actually sent
    # decoded_token = JWT.decode token, cert_finder.client_cert.public_key, true, { algorithm: 'RS256' }
    #
    # puts decoded_token

    http = Net::HTTP.new(server_url.host, server_url.port)
    http.use_ssl = true

    if server_url.host.include?('irs.gov')
      # Just cert and key are required
      http.cert = cert_finder.client_cert
      http.key = cert_finder.client_key
    elsif server_url.host.include?('cloud.gov')
      # No mTLS on this endpoint
    elsif server_url.host.include?('localhost')
      # nginx config for fake API server currently expects a cert + key + CA
      http.cert = cert_finder.client_cert
      http.key = cert_finder.client_key

      # In most cases, we can omit this as the signing CA cert is already in the system's trust store.
      # However, since we are self-signing and it currently isn't in the trust store we need to provide it.
      server_ca_cert_path = File.join(CertificateFinder.certs_dir, 'ca.crt')
      http.ca_file = server_ca_cert_path
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
    decipher.key = cert_finder.client_key.private_decrypt(Base64.decode64(response.header['SESSION-KEY']))
    decipher.iv = Base64.decode64(response.header['INITIALIZATION-VECTOR'])
    encrypted_tax_return_bytes = Base64.decode64(JSON.parse(response.body)['taxReturn'])

    if ENV['IRS_API_MTLS'] || ENV['IRS_API_NO_MTLS']
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

  class CertificateFinder
    attr_reader :server_url
    attr_reader :state_code

    def initialize(server_url, state_code)
      @server_url = server_url
      @state_code = state_code
    end

    def self.certs_dir
      File.join(__dir__, '..', '..', 'df_api')
    end

    def certs_dir
      self.class.certs_dir
    end

    def client_cert
      OpenSSL::X509::Certificate.new(client_cert_bytes)
    end

    def client_cert_bytes
      if server_url.host.include?('irs.gov')
        Base64.decode64(EnvironmentCredentials.dig('statefile', state_code, "cert_base64"))
      elsif server_url.host.include?('cloud.gov')
        File.read(File.join(certs_dir, "#{state_code}-cert.pem.txt"))
      elsif server_url.host.include?('localhost')
        File.read(File.join(certs_dir, 'client.crt'))
      end
    end

    def client_key
      OpenSSL::PKey::RSA.new(client_key_bytes)
    end

    def client_key_bytes
      if server_url.host.include?('irs.gov')
        Base64.decode64(EnvironmentCredentials.dig('statefile', state_code, "private_key_base64"))
      elsif server_url.host.include?('cloud.gov')
        File.read(File.join(certs_dir, "#{state_code}-key.pem.txt"))
      elsif server_url.host.include?('localhost')
        File.read(File.join(certs_dir, 'client.key'))
      end
    end
  end

  def self.server_url
    if ENV['IRS_API_MTLS']
      URI.parse(EnvironmentCredentials.dig(:statefile, :df_api_mtls))
    elsif ENV['IRS_API_NO_MTLS']
      URI.parse(EnvironmentCredentials.dig(:statefile, :df_api_no_mtls))
    elsif ENV['IRS_API_LOCALHOST']
      URI.parse('https://localhost:443/')
    end
  end
end
