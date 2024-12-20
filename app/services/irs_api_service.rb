require 'net/http'
require 'net/https'
require 'uri'
require 'jwt'
require 'nokogiri'
require 'openssl/oaep'

require_relative 'state_file/direct_file_api_response_sample_service'

class IrsApiService
  def self.df_return_sample
    StateFile::DirectFileApiResponseSampleService.new.old_xml_sample
  end

  def self.import_federal_data(authorization_code, _state_code)
    unless Rails.env.production?
      direct_file_api_response_sample_service = StateFile::DirectFileApiResponseSampleService.new
      if direct_file_api_response_sample_service.include?(authorization_code, 'xml')
        return {
          'xml' => direct_file_api_response_sample_service.read_xml(authorization_code),
          'submissionId' => direct_file_api_response_sample_service.lookup_submission_id(authorization_code),
          'status' => "accepted",
          'directFileData' => direct_file_api_response_sample_service.read_json(authorization_code)
        }
      end
    end

    account_id = EnvironmentCredentials.dig('statefile', _state_code, "account_id")
    cert_finder = CertificateFinder.new(server_url, _state_code)

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

    if server_url.host.ends_with?('irs.gov')
      # Just cert and key are required
      http.cert = cert_finder.client_cert
      http.key = cert_finder.client_key
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

    if ENV['IRS_SAVE_RESPONSE']
      # Capture the entire response (body + headers) from the IRS in a file
      filename = "irs_api_response-#{authorization_code}-#{Time.now.strftime("%Y-%m-%d")}.txt"
      save_response(response, filename)
    end

    if response.body.nil?
      raise StandardError, "DF export-return API response Error: response.body is nil. status=#{response.code}; header=#{response.header}"
    end

    undecrypted_body_json = JSON.parse(response.body)
    if undecrypted_body_json.include?("status") && undecrypted_body_json["status"] == "error"
      raise StandardError, "DF export-return API Response Error: #{undecrypted_body_json["error"]}"
    end

    unless response.header['SESSION-KEY']
      Rails.logger.error("Could not find SESSION-KEY in response header, bailing out. status=#{response.code}; header=#{response.header}; body=#{response.body}")
      return
    end

    decipher = OpenSSL::Cipher.new('aes-256-gcm')
    decipher.decrypt
    client_key = cert_finder.client_key
    encrypted_session_key = Base64.decode64(response.header['SESSION-KEY'])

    label = ''
    md_oaep = OpenSSL::Digest::SHA256
    md_mgf1 = OpenSSL::Digest::SHA1

    decipher.key = client_key.private_decrypt_oaep(encrypted_session_key, label, md_oaep, md_mgf1)
    decipher.iv = Base64.decode64(response.header['INITIALIZATION-VECTOR'])
    encrypted_tax_return_bytes = Base64.decode64(JSON.parse(response.body)['taxReturn'])

    if ENV['IRS_API_LOCALHOST']
      decipher.auth_tag = Base64.decode64(response.header['AUTHENTICATION-TAG'])
    else
      char_array = encrypted_tax_return_bytes.unpack("C*")
      encrypted_tax_return_bytes = char_array[0..-17].pack("C*")
      auth_tag = char_array.last(16).pack("C*")

      decipher.auth_tag = auth_tag
    end
    plain = decipher.update(encrypted_tax_return_bytes) + decipher.final

    decrypted_json = JSON.parse(plain)
    decrypted_json['xml'] = Nokogiri::XML(decrypted_json['xml']).to_xml

    decrypted_json
  end

  private

  class CertificateFinder
    attr_reader :server_url
    attr_reader :state_code

    def initialize(server_url, _state_code)
      @server_url = server_url
      @state_code = _state_code
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
      if server_url.host.ends_with?('irs.gov')
        Base64.decode64(EnvironmentCredentials.dig('statefile', state_code, "cert_base64"))
      elsif server_url.host.include?('localhost')
        File.read(File.join(certs_dir, 'client.crt'))
      end
    end

    def client_key
      OpenSSL::PKey::RSA.new(client_key_bytes)
    end

    def client_key_bytes
      if server_url.host.ends_with?('irs.gov')
        Base64.decode64(EnvironmentCredentials.dig('statefile', state_code, "private_key_base64"))
      elsif server_url.host.include?('localhost')
        File.read(File.join(certs_dir, 'client.key'))
      end
    end
  end

  def self.server_url
    if ENV['IRS_API_LOCALHOST']
      URI.parse('https://localhost:443/')
    else
      URI.parse(EnvironmentCredentials.dig(:statefile, :df_api_mtls))
    end
  end

  def self.save_response(response, filename)
    File.open(filename, 'w') do |file|
      response.each_header do |key, value|
        file.puts "#{key}: #{value}"
      end
      file.puts "-" * 20
      file.write(response.body)
    end
    puts "Response saved to #{filename}"
  end
end
