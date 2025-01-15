class ArchivedIntakeEmailVerificationCodeService
  def initialize(email_address: , locale: :en)
    @email_address = email_address
    @locale = locale
  end

  def request_code
    verification_code, = EmailAccessToken.generate!(email_address: @email_address)
    VerificationCodeMailer.archived_intake_verification_code(
      to: @email_address,
      verification_code: verification_code,
      locale: @locale
    ).deliver_now
  end

  def self.request_code(**args)
    new(**args).request_code
  end
end