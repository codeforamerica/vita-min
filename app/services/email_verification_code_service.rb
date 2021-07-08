class EmailVerificationCodeService
  SERVICE_TYPES = [:ctc, :gyr]
  def initialize(email_address: , locale: :en, visitor_id: , client_id: nil, service_type: :gyr)
    raise(ArgumentError, "Unsupported service_type: #{service_type}") unless SERVICE_TYPES.include? service_type.to_sym

    @service_type = service_type.to_sym
    @email_address = email_address
    @locale = locale
    @visitor_id = visitor_id
    @client_id = client_id
  end

  def request_code
    send_verification_code
  end

  private

  # sends an email synchronously using deliver_now so that we can store the mailgun ID,
  # so best to send this from a background job.
  def send_verification_code
    verification_code, access_token = generate_verification_code
    mailer_response = VerificationCodeMailer.with(
      to: @email_address,
      verification_code: verification_code,
      locale: @locale,
      service_type: @service_type
    ).with_code.deliver_now
    VerificationEmail.create!(
      email_access_token: access_token,
      visitor_id: @visitor_id,
      mailgun_id: mailer_response.message_id
    )
  end

  def generate_verification_code
    existing_tokens = EmailAccessToken.where(email_address: @email_address, token_type: "verification_code")
    existing_tokens.order(created_at: :asc).limit(existing_tokens.count - 4).delete_all if existing_tokens.count > 4
    raw_verification_code, hashed_verification_code = VerificationCodeService.generate(@email_address)
    DatadogApi.increment("client_logins.verification_codes.email.created")
    [raw_verification_code, EmailAccessToken.create!(
      email_address: @email_address,
      token_type: "verification_code",
      token: Devise.token_generator.digest(EmailAccessToken, :token, hashed_verification_code),
      client_id: @client_id
    )]
  end

  def self.request_code(*args)
    new(*args).request_code
  end
end