module StateFile
  class MessagingService
    def self.send_email(intake:, subject:, body:)
      raise ArgumentError unless intake.present? && subject.present? && body.present?
      return unless intake.email_address.present? && intake.email_address_verified_at.present?

      StateFileNotificationEmail.create!(
        to: intake.email_address,
        body: body,
        subject: subject,
        )
    end

    def self.send_notification(intake:, message:, body_args: {})
      # TODO: Figure out locale from intake somehow (though we don't currently capture preferred language anywhere)
      locale = nil

      body_args[:client_preferred_name] ||= intake.primary_first_name

      send_email(intake: intake,
                 subject: message.email_subject(locale: locale),
                 body: message.email_body(locale: locale, **body_args))
      # Eventually send SMS here as well
    end
  end
end
