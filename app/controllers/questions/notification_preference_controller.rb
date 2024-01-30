module Questions
  class NotificationPreferenceController < QuestionsController
    include AnonymousIntakeConcern
    private

    def self.show?(intake)
      false
    end
    def tracking_data
      @form.attributes_for(:intake).reject { |k, _| k == :sms_phone_number }
    end

    def illustration_path
      "contact-preference.svg"
    end
  end
end
