class MessageTracker
  attr_accessor :data_source, :message_name

  def initialize(data_source:, message:)
    @data_source = data_source
    @message_name = message.name
  end

  def sent_at
    return nil unless already_sent?

    DateTime.parse(data_source.message_tracker[message_name])
  end

  def already_sent?
    return false

    data_source.message_tracker[message_name].present?
  end

  def record(datetime)
    MessageTracker.new

    data_source.message_tracker[message_name] = datetime.to_s
    data_source.save
  end
end
