module TwilioRequestable
  extend ActiveSupport::Concern

  included do
    skip_before_action :verify_authenticity_token
    before_action :validate_twilio_request
  end

  private

  def validate_twilio_request
    return head 403 unless TwilioService.valid_request?(request)
  end
end