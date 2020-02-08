module Questions
  class NotificationPreferenceController < QuestionsController
    private

    def section_title
      "Personal Information"
    end

    def illustration_path; end

    def after_update_success
      if current_intake.intake_ticket_id.blank?
        service = ZendeskIntakeService.new(current_intake)
        if current_intake.intake_ticket_requester_id.blank?
          current_intake.update(
            intake_ticket_requester_id: service.create_intake_ticket_requester
          )
        end
        current_intake.update(
          intake_ticket_id: service.create_intake_ticket
        )
      end
    end

    def custom_tracking_data
      @form.attributes_for(:user)
    end
  end
end
