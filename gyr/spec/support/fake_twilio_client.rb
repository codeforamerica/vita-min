class FakeTwilioClient
  # HT Thoughtbot: https://robots.thoughtbot.com/testing-sms-interactions

  cattr_accessor :messages
  self.messages = []

  def initialize(*_args)
  end

  def messages(*args)
    message_context = FakeTwilioMessageContext.new(args)
    message_context.client = self
    message_context
  end
end

class FakeTwilioMessage
  attr_accessor :messaging_service_sid, :to, :from, :body, :sid, :date_created, :date_updated, :date_sent, :direction, :error_code, :error_message, :status

  def initialize(params)
    @messaging_service_sid = params[:messaging_service_sid]
    @to = params[:to]
    @body = params[:body]
    @sid = params[:sid]
    @date_updated = params[:date_updated]
    @date_created = params[:date_created]
    @direction = params[:direction]
    @date_sent = params[:date_sent]
    @error_code = params[:error_code]
    @error_message = params[:error_message]
    @status = params[:status]
  end
end

class FakeTwilioMessageContext
  attr_accessor :client

  def initialize(args)
    @args = args
  end

  def create(args)
    message = FakeTwilioMessage.new(args.merge(sid: 'FAKE_TWILIO_SID'))
    FakeTwilioClient.messages << message
    message
  end
end
