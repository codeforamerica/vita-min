module StateFile
  class MessagingService
    attr_accessor :locale, :message, :intake, :submission, :locale, :message_tracker, :sent_messages

    def initialize(message:, intake:, submission: nil, locale: nil, sms: true, email: true, body_args: {})
      @locale = locale || "en" # TODO: add intake.locale once we start collecting it
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

    def send_message
      return nil if message_tracker.already_sent? && message.send_only_once?

      send_email if @do_email
      # send_sms if @do_sms # TODO: Eventually send SMS when fixed

      message_tracker.record(sent_messages.last.created_at) if sent_messages.any? # will this be recorded correctly with what we have on line 40

      sent_messages
    end

    private

    def send_email
      return unless Flipper.enabled?(:state_file_notification_emails) && intake.email_address.present? && intake.email_address_verified_at.present?

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
    
    # def send_sms
    #   return unless Flipper.enabled?(:sms_notifications)
    # end

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
