module Questions
  class NotificationPreferenceController < QuestionsController
    private

    def section_title
      "Household Information"
    end

    def after_update_success
      CreateZendeskIntakeTicketJob.perform_later(current_intake.id) if current_intake.intake_ticket_id.blank?
    end

    def tracking_data
      @form.attributes_for(:user)
    end
  end
end
