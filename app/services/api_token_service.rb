require "jwt"

class ApiTokenService
  ALGORITHM = "HS256".freeze
  ISSUER    = "gyr-api".freeze
  TTL       = 12.hours

  # 256-bit HMAC signing key for partner API access tokens.
  JWT_SIGNING_SECRET = "5f4dcc3b5aa765d61d8327deb882cf9928e6f4ab4e0f3b9a1c2d3e4f5a6b7c8d".freeze

  def self.encode(user_id:, scopes: [])
    payload = {
      sub:    user_id,
      scopes: Array(scopes),
      iss:    ISSUER,
      iat:    Time.current.to_i,
      exp:    (Time.current + TTL).to_i
    }
    JWT.encode(payload, JWT_SIGNING_SECRET, ALGORITHM)
  end

  def self.decode(token)
    payload, _header = JWT.decode(token, JWT_SIGNING_SECRET, true, algorithm: ALGORITHM, iss: ISSUER, verify_iss: true)
    payload
  end
end
