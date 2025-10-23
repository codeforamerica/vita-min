#!/usr/bin/env ruby

require_relative "../config/environment"

class TestStateApiV2 < Thor
  desc 'access_token <kid> <client_id> <private_key_path>', 'Retrieves an OAuth access token for subsequent requests'
  def access_token(kid, client_id, private_key_path)
    say "Retrieving an access token", :green

    host = "https://api.alt.www4.irs.gov"
    path = "/auth/oauth/v2/token"

    headers = {
      alg: "RS256",
      typ: "JWT",
      kid: kid
    }
    body = {
      aud: host + path,
      iss: client_id,
      sub: client_id,
      exp: Time.now.to_i + 15 * 60,
      jti: SecureRandom.uuid
    }
    private_key = OpenSSL::PKey::RSA.new(File.binread(private_key_path))
    jwt = JWT.encode(body, private_key, "RS256", headers)

    connection = Faraday.new(
      url: host,
      headers: {"Content-Type" => " application/x-www-form-urlencoded"}
    )
    response = connection.post(path) do |req|
      req.params = {
        grant_type: "client_credentials",
        client_assertion_type: "urn:ietf:params:oauth:client-assertion-type:jwt-bearer",
        client_assertion: jwt
      }
    end

    if JSON.parse(response.body).key?("access_token")
      say "Retrieved access token: #{JSON.parse(response.body)["access_token"]}", :green
    else
      say "Failed to retrieve access token", :red
      say response.body, :red
    end
  end

  desc 'test_connection <access_token> <client_id> <private_key_path>', 'Hits an endpoint meant to test an access token'
  def test_connection(access_token, client_id, private_key_path)
    say "Sending request to test connection endpoint", :green

    host = "https://api.alt.www4.irs.gov"
    path = "/direct-file/state-api/v2/test/connection"

    connection = Faraday.new(
      url: host,
      headers: {
        "Content-Type" => " application/json",
        "Authorization" => "Bearer #{access_token}",
        "enterpriseBusCorrelationId" => "#{SecureRandom.uuid}:DFS00:#{client_id[-12..]}:T"
      }
    )
    response = connection.post(path)
    response_json = JSON.parse(response.body)

    unless response_json.key?("data")
      say "Received an invalid response", :red
      say response.body, :red
      exit
    end

    decrypted_response = IrsApiService.decrypt_response(
      OpenSSL::PKey::RSA.new(File.binread(private_key_path)),
      Base64.decode64(response_json["decryptionInputs"]["encryptedSecret"]),
      Base64.decode64(response_json["decryptionInputs"]["initializationVector"]),
      Base64.decode64(response_json["data"]),
      Base64.decode64(response_json["decryptionInputs"]["authenticationTag"])
    )

    say "Received a valid response", :green
    say JSON.parse(decrypted_response), :green
  end
end

TestStateApiV2.start
