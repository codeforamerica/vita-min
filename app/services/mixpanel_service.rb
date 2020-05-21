require "singleton"

class MixpanelService
  include Singleton

  def initialize
    mixpanel_key = Rails.application.credentials.dig(Rails.env.to_sym, :mixpanel_token)
    return if mixpanel_key.nil?

    @tracker = Mixpanel::Tracker.new(mixpanel_key)
    # silence local SSL errors
    if Rails.env.development?
      Mixpanel.config_http do |http|
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end
  end

  def run(unique_id:, event_name:, data: {})
    @tracker.track(unique_id, event_name, data)
  rescue StandardError => err
    Rails.logger.error "Error tracking analytics event #{err}"
  end
end
