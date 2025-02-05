module StateFile
  class MessagingService
    DEFAULT_LOCALE = 'en'.freeze
    attr_accessor :locale, :message, :intake, :submission, :locale, :message_tracker, :sent_messages

    def initialize(message:, intake:, submission: nil, locale: nil, sms: true, email: true, body_args: {})
      @locale = locale || intake.locale || DEFAULT_LOCALE
      @message = message
      @message_instance = message.new
      @intake = intake
      @submission = submission.nil? ? intake.efile_submissions.last : submission
      @sent_messages = []
      @body_args = body_args
      @do_sms = sms
      @do_email = email
    end

    def message_tracker
      data_source = @message.after_transition_notification? ? submission : intake
      @message_tracker ||= MessageTracker.new(data_source: data_source, message: message)
    end

    def send_message(require_verification: true)
      return nil if message_tracker.already_sent? && message.send_only_once?

      send_email(require_verification: require_verification) if @do_email && !intake.unsubscribed_from_email? && !intake.email_notification_opt_in_no?
      if intake.unsubscribed_from_email?
        DatadogApi.increment("mailgun.state_file_notification_emails.not_sent_because_unsubscribed")
      end

      send_sms(require_verification:) if @do_sms && !intake.sms_notification_opt_in_no?

      message_tracker.record(sent_messages.last.created_at) if sent_messages.any? # will this be recorded correctly with what we have on line 40

      sent_messages
    end

    private

    def send_email(require_verification: true)
      email_verified = intake.email_address_verified_at.present? || matching_intakes_has_email_verified_at?(intake)
      return if intake.email_address.nil?
      return if require_verification && !email_verified
      return if intake.unsubscribed_from_email?

      if @message_instance.email_body.present?
        sent_message = StateFileNotificationEmail.create!(
          data_source: intake,
          to: intake.email_address,
          body: @message_instance.email_body(locale: locale, **email_args),
          subject: @message_instance.email_subject(locale: @locale, **email_args),
        )
        sent_messages << sent_message if sent_message.present?
      end
    end

    def send_sms(require_verification: true)
      phone_number_verified = intake.phone_number_verified_at.present? || matching_intakes_has_phone_number_verified_at?(intake)
      return if intake.phone_number.nil?
      return if require_verification && !phone_number_verified

      if @message_instance.sms_body.present?
        sent_message = StateFileNotificationTextMessage.create!(
          data_source: intake,
          to_phone_number: intake.phone_number,
          body: @message_instance.sms_body(locale: locale, **sms_args),
        )
        sent_messages << sent_message if sent_message.present?
      end
    end
    
    def matching_intakes_has_email_verified_at?(intake)
      return if intake.email_address.nil? || intake.hashed_ssn.nil?

      intake_class = StateFile::StateInformationService.intake_class(intake.state_code)
      matching_intakes = intake_class.where(email_address: intake.email_address, hashed_ssn: intake.hashed_ssn)
                                     .where.not(email_address_verified_at: nil)
      matching_intakes.present?
    end

    def matching_intakes_has_phone_number_verified_at?(intake)
      return if intake.phone_number.nil? || intake.hashed_ssn.nil?

      intake_class = StateFile::StateInformationService.intake_class(intake.state_code)
      matching_intakes = intake_class.where(phone_number: intake.phone_number, hashed_ssn: intake.hashed_ssn)
                                     .where.not(phone_number_verified_at: nil)
      matching_intakes.present?
    end

    def base_args
      first_name = intake.primary_first_name ? intake.primary_first_name.split(/ |\_/).map(&:capitalize).join(" ") : ""
      {
        locale: locale,
        primary_first_name: first_name,
        state_name: intake.state_name,
        state_code: intake.state_code
      }
    end

    def email_args
      base_args.merge(@body_args)
    end

    def sms_args
      base_args.merge(@body_args)
    end
  end
end
