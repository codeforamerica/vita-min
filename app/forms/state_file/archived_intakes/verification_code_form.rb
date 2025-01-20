module StateFile
  module ArchivedIntakes
    class VerificationCodeForm < Form
      attr_accessor :verification_code, :email_address

      validates :verification_code, presence: true
      def initialize(attributes = {}, email_address: nil)
        super(attributes)
        @email_address = email_address
      end

      def valid?
        return true if Rails.configuration.allow_magic_verification_code && verification_code == "000000"

        hashed_verification_code = VerificationCodeService.hash_verification_code_with_contact_info(@email_address, verification_code)

        valid_code = EmailAccessToken.lookup(hashed_verification_code).exists?

        errors.add(:verification_code, I18n.t("state_file.archived_intakes.verification_code.edit.error_message")) unless valid_code

        valid_code.present?
      end
    end
  end
end
