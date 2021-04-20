module Hub
  class OutboundCallForm < Form
    attr_accessor :user_phone_number, :client_phone_number, :outbound_call, :twilio_phone_number
    delegate :dial_client_path,
      :dial_client_url,
      :twilio_connect_to_client_url, to: 'Rails.application.routes.url_helpers'

    before_validation do
      self.user_phone_number = PhoneParser.normalize(user_phone_number)
      self.client_phone_number = PhoneParser.normalize(client_phone_number)
    end

    validates :user_phone_number, e164_phone: true
    validates :client_phone_number, e164_phone: true

    def initialize(attrs = {}, **kwargs)
      @user = kwargs[:user]
      @client = kwargs[:client]

      self.twilio_phone_number = EnvironmentCredentials.dig(:twilio, :voice_phone_number)
      self.user_phone_number = @user&.phone_number
      self.client_phone_number = @client&.phone_number
      super(attrs)
    end

    def dial
      return false unless valid?

      twilio_client = Twilio::REST::Client.new(EnvironmentCredentials.dig(:twilio, :account_sid),
                                               EnvironmentCredentials.dig(:twilio, :auth_token))
      OutboundCall.transaction do
        @outbound_call = @client.outbound_calls.create(
          user_id: @user.id,
          to_phone_number: client_phone_number,
          from_phone_number: user_phone_number
        )

        twilio_call = twilio_client.calls.create(
          twiml: twiml,
          to: user_phone_number,
          from: twilio_phone_number
        )

        DatadogApi.increment("twilio.outbound_calls.initiated")

        @outbound_call.update(twilio_sid: twilio_call.sid, twilio_status: twilio_call.status, queue_time_ms: twilio_call.queue_time)
      end
    end

    private

    # initiates a call to the from phone number when any number is pressed.
    # If a number is pressed, the call will redirect to another twilio url that connects the call to the client
    # After 5 seconds without a response the call will hang up.
    def twiml
      twiml = Twilio::TwiML::VoiceResponse.new
      twiml.gather(action: twilio_connect_to_client_url(id: @outbound_call.id, locale: nil), num_digits: 1, timeout: 15) do |g|
        g.say(message: "Press any number to connect your Get Your Refund call.")
      end
      # this code only executes if the user does not enter a digit within the timeout period (5 secs)
      twiml.say(message: "We didn't hear from you so we're hanging up!")
      twiml.hangup
      twiml.to_xml
    end
  end
end