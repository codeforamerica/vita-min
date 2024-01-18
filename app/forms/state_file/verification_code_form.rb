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
      is_first_time_verifying = intake.phone_number_verified_at.blank? && intake.email_address_verified_at.blank?
      intake.touch(:phone_number_verified_at) if is_text_based?
      intake.touch(:email_address_verified_at) if is_email_based?
      if Flipper.enabled? :state_file_notification_emails
        if is_first_time_verifying
          StateFile::MessagingService.send_notification(
            intake: intake,
            message: StateFile::NotificationMessages::Welcome)
        end
      end
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