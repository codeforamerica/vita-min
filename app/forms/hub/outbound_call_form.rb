module Hub
  class OutboundCallForm < Form
    attr_accessor :user_phone_number, :client_phone_number, :outbound_call
    delegate :dial_path,
      :dial_url,
      :outbound_calls_webhook_path,
      :outbound_calls_webhook_url, to: 'Rails.application.routes.url_helpers'

    before_validation do
      self.user_phone_number = PhoneParser.normalize(user_phone_number)
      self.client_phone_number = PhoneParser.normalize(client_phone_number)
    end

    validates :user_phone_number, phone: true
    validates :client_phone_number, phone: true

    def initialize(attrs = {}, **kwargs)
      @user = kwargs[:user]
      @client = kwargs[:client]

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
          url: dial_callback_url,
          to: user_phone_number,
          from: EnvironmentCredentials.dig(:twilio, :voice_phone_number)
        )

        outbound_call.update(twilio_sid: twilio_call.sid, twilio_status: twilio_call.status)
      end
    end

    private

    def dial_callback_url
      params = { id: @outbound_call.id, locale: nil }
      if Rails.env.development?
        raise NgrokNeededError unless Rails.configuration.try(:ngrok_url).present?

        return Rails.configuration.ngrok_url + dial_path(params)
      end
      dial_url(params)
    end

    def webhook_url
      params = { id: @outbound_call.id, locale: nil }

      if Rails.env.development?
        raise NgrokNeededError unless Rails.configuration.try(:ngrok_url).present?

        return Rails.configuration.ngrok_url + outbound_calls_webhook_path(params)
      end
      outbound_calls_webhook_url(params)
    end

    class NgrokNeededError < StandardError
    end
  end
end