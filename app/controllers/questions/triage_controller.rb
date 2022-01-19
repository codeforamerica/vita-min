module Questions
  class TriageController < QuestionsController
    include PreviousPathIsBackConcern
    before_action :set_show_client_sign_in_link
    before_action :redirect_if_matching_source_param
    before_action :require_triage

    private

    def require_triage
      unless current_triage
        redirect_to Questions::TriageIncomeLevelController.to_path_helper
      end
    end

    def initialized_edit_form
      form_class.from_record(current_triage)
    end

    def initialized_update_form
      form_class.new(current_triage, form_params)
    end

    def track_question_answer
      send_mixpanel_event(event_name: "answered_question", data: form_attributes, subject: "triage")
    end

    def form_attributes
      return {} unless @form.class.scoped_attributes.key?(:triage)

      @form.attributes_for(:triage)
    end

    def redirect_if_matching_source_param
      redirect_to backtaxes_questions_path if SourceParameter.find_vita_partner_by_code(session[:source]).present?
    end

    def set_show_client_sign_in_link
      @show_client_sign_in_link = true
    end
  end
end
