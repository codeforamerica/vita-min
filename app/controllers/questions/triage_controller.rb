module Questions
  class TriageController < QuestionsController
    include AnonymousIntakeConcern
    include PreviousPathIsBackConcern
    before_action :redirect_if_matching_source_param
    skip_before_action :require_intake

    def edit
      @form = form_class.new
    end

    def update
      @form = form_class.new(form_params)
      render :edit and return unless @form.valid?

      send_mixpanel_event(event_name: "answered_question", data: form_attributes, subject: "triage")
      redirect_to next_path
    end

    private

    def form_attributes
      return {} unless @form.class.scoped_attributes.key?(:triage)

      @form.attributes_for(:triage).except(*Rails.application.config.filter_parameters)
    end

    def redirect_if_matching_source_param
      redirect_to file_with_help_questions_path if SourceParameter.find_vita_partner_by_code(session[:source]).present?
    end
  end
end
