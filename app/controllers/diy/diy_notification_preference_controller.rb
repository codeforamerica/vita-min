module Diy
  class DiyNotificationPreferenceController < BaseController
    private

    def tracking_data
    #  @form.attributes_for(:intake).reject { |k, _| k == :sms_phone_number }
    end

    def illustration_path
      "contact-preference.svg"
    end
  end
end
