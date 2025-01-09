module StateFile
  module ArchivedIntakes
    class VerificationCodeForm < Form
      attr_accessor :verification_code, :email_address

      validates :verification_code, presence: true
      def initialize(attributes = {}, email_address: nil)
        super(attributes) # Pass attributes to the parent class
        @email_address = email_address # Assign email_address to an instance variable
        assign_attributes(attributes)
      end


      def valid?
        hashed_verification_code = VerificationCodeService.hash_verification_code_with_contact_info(@email_address, verification_code)
        # # Magic codes provide a way of bypassing security in a development context.
        # # The easiest way to do this was to update the last entry to actually have the magic code.
        # if Rails.configuration.allow_magic_verification_code && verification_code == "000000"
        #   token = EmailAccessToken.where(email_address: @intake.email_address).last
        #   if token.present?
        #     token.update(
        #       token: Devise.token_generator.digest(EmailAccessToken, :token, hashed_verification_code),
        #       )
        #   end
        #   return true
        # end

        valid_code = EmailAccessToken.lookup(hashed_verification_code).exists?

        errors.add(:verification_code, I18n.t("views.questions.verification.error_message")) unless valid_code

        valid_code.present?
      end
      def save
        run_callbacks :save do
          valid?
        end
      end
    end
  end
end
