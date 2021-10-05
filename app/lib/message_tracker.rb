class MessageTracker
  attr_accessor :client, :message_name

  def initialize(client:, message:)
    @client = client
    @message_name = message.name
  end

  def sent_at
    return nil unless already_sent?

    DateTime.parse(client.message_tracker[message_name])
  end

  def already_sent?
    client.message_tracker[message_name].present?
  end

  def record(datetime)
    client.message_tracker[message_name] = datetime.to_s
    client.save
  end
end