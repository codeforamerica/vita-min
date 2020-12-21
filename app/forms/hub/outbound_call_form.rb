module Hub
  class OutboundCallForm < Form
    attr_accessor :user_phone_number, :client_phone_number
    delegate :call_hub_client_path,
      :call_hub_client_url,
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

    def call!
      return false unless valid?

      twilio_client = Twilio::REST::Client.new(EnvironmentCredentials.dig(:twilio, :account_sid),
                                                EnvironmentCredentials.dig(:twilio, :auth_token))
      call = twilio_client.calls.create(
        url: call_url,
        to: user_phone_number,
        from: '+14156393361',
        status_callback: webhook_url
      )
      return false unless call.sid.present?

      @client.outbound_calls.create(
        user_id: @user.id,
        to_phone_number: client_phone_number,
        from_phone_number: user_phone_number,
        twilio_sid: call.sid,
        twilio_status: call.status
      )
    end

    private

    def call_url
      params = { id: @client.id, phone_number: client_phone_number }

      if Rails.env.development?
        raise NgrokNeededError unless Rails.configuration.try(:ngrok_url).present?

        return Rails.configuration.ngrok_url + call_hub_client_path(params)
      end
      call_hub_client_url(params)
    end

    def webhook_url
      if Rails.env.development?
        raise NgrokNeededError unless Rails.configuration.try(:ngrok_url).present?

        return Rails.configuration.ngrok_url + outbound_calls_webhook_path(locale: nil)
      end
      outbound_calls_webhook_url(locale: nil)
    end

    class NgrokNeededError < StandardError
    end
  end
end