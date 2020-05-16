module Questions
  class NotificationPreferenceController < QuestionsController
    before_action :returning_client_guard
    private

    def tracking_data
      @form.attributes_for(:intake).reject { |k, _| k == :sms_phone_number }
    end

    def returning_client_guard
      if DuplicateIntakeGuard.new(current_intake).has_duplicate?
        redirect_to returning_client_path
      end
    end
  end
end
