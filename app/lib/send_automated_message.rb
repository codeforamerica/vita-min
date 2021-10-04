class SendAutomatedMessage
  attr_accessor :locale, :message, :message_name, :tax_return, :locale, :message_tracker, :sent_messages, :client

  def initialize(client:, message:, tax_return: nil, locale: nil, message_name: nil)
    @client = client
    @locale = locale || client.intake.locale || "en"
    @message = message
    @tax_return = tax_return
    @message_name = message_name || @message.class.name
    @sent_messages = []
  end

  def message_tracker
    @message_tracker ||= MessageTracker.new(client: client, message_name: message_name)
  end

  def send_messages
    return nil if message_tracker.already_sent?

    send_email
    send_sms

    message_tracker.record(sent_messages.last.created_at) if sent_messages.any?

    sent_messages
  end

  private

  def base_args
    {
      client: client,
      locale: locale,
      tax_return: tax_return
    }
  end

  def email_args
    base_args.merge({
      body: message.email_body(locale: locale),
      subject: message.email_subject(locale: locale)
    })
  end

  def sms_args
    base_args.merge({
      body: message.sms_body(locale: locale)
    })
  end

  def send_email
    if client.intake.email_notification_opt_in_yes? && client.email_address.present? && message.email_body.present?
      sent_messages << ClientMessagingService.send_system_email(**email_args)
    end
  end

  def send_sms
    if client.intake.sms_notification_opt_in_yes? && client.sms_phone_number.present? && message.sms_body.present?
      sent_messages << ClientMessagingService.send_system_text_message(**sms_args)
    end
  end
end