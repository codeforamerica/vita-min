class ArchivedIntakeEmailVerificationCodeService
  def initialize(email_address: , locale: :en)
    @service_data = MultiTenantService.new(:statefile)
    @email_address = email_address
    @locale = locale
  end

  def request_code
    _, verification_code = EmailAccessToken.generate!(email_address: @email_address)
    VerificationCodeMailer.with(
      to: @email_address,
      verification_code: verification_code,
      locale: @locale
    ).archived_intake_verification_code.deliver_now
  end

  private

  def self.request_code(**args)
    new(**args).request_code
  end
end