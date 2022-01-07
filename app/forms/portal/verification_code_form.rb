module Portal
  class VerificationCodeForm < Form
    include PhoneNumberHelper
    attr_accessor :contact_info, :verification_code
    validates :verification_code, format: { with: /\A[0-9]{6}\z/ }

    def formatted_contact_info
      return contact_info if contact_info.include?("@")

      PhoneParser.formatted_phone_number(contact_info)
    end
  end
end
