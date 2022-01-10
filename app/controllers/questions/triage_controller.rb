module Questions
  class TriageController < QuestionsController
    include AnonymousIntakeConcern
    include PreviousPathIsBackConcern
    before_action :redirect_if_matching_source_param
    skip_before_action :require_intake

    def edit
      @form = form_class.new
    end

    private

    def current_triage
      @_current_triage ||= (Triage.find_by_id(session[:triage_id]) unless session[:triage_id].nil?)
    end

    def initialized_update_form
      form_class.new(form_params)
    end

    def track_question_answer
      send_mixpanel_event(event_name: "answered_question", data: form_attributes, subject: "triage")
    end

    def form_attributes
      return {} unless @form.class.scoped_attributes.key?(:triage)

      @form.attributes_for(:triage)
    end

    def redirect_if_matching_source_param
      redirect_to file_with_help_questions_path if SourceParameter.find_vita_partner_by_code(session[:source]).present?
    end
  end
end
