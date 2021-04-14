module Questions
  class TriageController < AnonymousIntakeController
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

    def prev_path
      :back
    end
  end
end
