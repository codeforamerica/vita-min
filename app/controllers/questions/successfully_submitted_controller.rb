module Questions
  class SuccessfullySubmittedController < TicketedQuestionsController
    skip_before_action :require_ticket
    append_after_action :set_completed_intake_session, :clear_intake_session, :track_page_view

    def include_analytics?
      true
    end

    private

    def initialized_update_form
      form_class.new(intake_from_completed_session, form_params)
    end

    def self.form_name
      "satisfaction_face_form"
    end

    def set_completed_intake_session
      return unless @form.intake.present?

      session[:completed_intake_id] = @form.intake.id
    end
  end
end
