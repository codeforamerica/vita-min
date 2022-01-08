class SendAutomatedMessage
  attr_accessor :locale, :message, :tax_return, :locale, :message_tracker, :sent_messages, :client

  def initialize(client:, message:, tax_return: nil, locale: nil, body_args: {})
    @client = client
    @locale = locale || client.intake.locale || "en"
    @message = message
    @message_instance = message.new
    @tax_return = tax_return
    @sent_messages = []
    @body_args = body_args
  end

  def message_tracker
    @message_tracker ||= MessageTracker.new(client: client, message: message)
  end

  def send_messages
    return nil if message_tracker.already_sent? && message.send_only_once?

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
      body: @message_instance.email_body(locale: locale, body_args: @body_args),
      subject: @message_instance.email_subject(locale: locale)
    })
  end

  def sms_args
    base_args.merge({
      body: @message_instance.sms_body(locale: locale, body_args: @body_args)
    })
  end

  def send_email
    if @message_instance.email_body.present?
      sent_message = ClientMessagingService.send_system_email(**email_args)
      sent_messages << sent_message if sent_message.present?
    end
  end

  def send_sms
    if @message_instance.sms_body.present?
      sent_message = ClientMessagingService.send_system_text_message(**sms_args)
      sent_messages << sent_message if sent_message.present?
    end
  end
end