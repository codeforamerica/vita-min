module Questions
  class NotificationPreferenceController < QuestionsController
    private

    def section_title
      "Personal Information"
    end

    def illustration_path; end

    def custom_tracking_data
      @form.attributes_for(:user)
    end
  end
end
