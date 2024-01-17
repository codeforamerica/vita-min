module StateFile
  class VerificationCodeForm < QuestionsForm
    set_attributes_for :misc, :verification_code

    def valid?
      # Delegate validation to a phone or email verification form.
      # If there's no contact preference, use the email form.
      validation_form_class = is_text_based? ? PhoneVerificationForm : EmailVerificationForm
      form = validation_form_class.new(intake, attributes_for(:misc))
      is_valid = form.valid?
      unless is_valid
        errors.add(:verification_code, form.errors[:verification_code])
      end

      is_valid
    end

    def save
      intake.touch(:phone_number_verified_at) if is_text_based?
      intake.touch(:email_address_verified_at) if is_email_based?
      StateFile::MessagingService.send_notification(
        intake: intake,
        message: AutomatedMessage::StateFile::Welcome.new)
    end

    private

    def is_text_based?
      intake.contact_preference == "text"
    end

    def is_email_based?
      intake.contact_preference == "email"
    end
  end
end