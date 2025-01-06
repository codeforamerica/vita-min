module Portal
  class ArchivedIntakeVerificationCodeForm < Form
    include PhoneNumberHelper
    attr_accessor :contact_info, :verification_code
    validates :verification_code, format: { with: /\A[0-9]{6}\z/ }
  end
end