module Questions
  class NotificationPreferenceController < QuestionsController
    private

    def tracking_data
      @form.attributes_for(:intake).reject { |k, _| k == :sms_phone_number }
    end
  end
end
