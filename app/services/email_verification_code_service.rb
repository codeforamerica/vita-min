class EmailVerificationCodeService
  def initialize(email_address: , locale: :en, visitor_id:, client_id: nil, service_type:)
    @service_data = MultiTenantService.new(service_type)
    @email_address = email_address
    @locale = locale
    @visitor_id = visitor_id
    @client_id = client_id
  end

  def request_code
    DatadogApi.increment("mailgun.verification_email.attempted", tags: ["service_type:#{@service_data.service_type}"])
    verification_code, access_token = EmailAccessToken.generate!(email_address: @email_address, client_id: @client_id)
    begin
      mailer_response = VerificationCodeMailer.with(
        to: @email_address,
        verification_code: verification_code,
        locale: @locale,
        service_type: @service_data.service_type
      ).with_code.deliver_now
      DatadogApi.increment("mailgun.verification_email.sent", tags: ["service_type:#{@service_data.service_type}"])
    rescue => e
      Sentry.capture_exception(e, extra: { client_id: @client_id })
      DatadogApi.increment("mailgun.verification_email.failed", tags: ["service_type:#{@service_data.service_type}"])
      raise
    end
    VerificationEmail.create!(
      email_access_token: access_token,
      visitor_id: @visitor_id,
      mailgun_id: mailer_response.message_id
    )
  end

  private

  def self.request_code(**args)
    new(**args).request_code
  end
end