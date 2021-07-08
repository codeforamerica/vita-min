class EmailVerificationCodeService
  SERVICE_TYPES = [:ctc, :gyr]
  def initialize(email_address: , locale: :en, visitor_id: , client_id: nil, service_type:)
    raise(ArgumentError, "Unsupported service_type: #{service_type}") unless SERVICE_TYPES.include? service_type.to_sym

    @service_type = service_type.to_sym
    @email_address = email_address
    @locale = locale
    @visitor_id = visitor_id
    @client_id = client_id
  end

  def request_code
    verification_code, access_token = EmailAccessToken.generate!(email_address: @email_address, client_id: @client_id)
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

  private

  def self.request_code(*args)
    new(*args).request_code
  end
end