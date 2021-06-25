module Stimulus
  class StimulusController < Questions::QuestionsController
    include AnonymousIntakeConcern
    skip_before_action :require_intake
    before_action :require_stimulus_triage

    layout "yes_no_question"

    def visitor_record
      current_stimulus_triage
    end

    def edit
      @form = form_class.from_stimulus_triage(current_stimulus_triage)
    end

    def update
      @form = form_class.new(current_stimulus_triage, form_params)
      if @form.valid?
        @form.save
        after_update_success
        redirect_to(next_path)
      else
        track_validation_error
        render :edit
      end
    end

    def current_path(params = {})
      path_for(params)
    end

    def next_path(params = {})
      next_step = form_navigation.next
      return unless next_step

      next_step.path_for(params)
    end

    def prev_path
      nil
    end

    def parent_class
      StimulusTriage
    end

    def illustration_folder
      "stimulus"
    end

    private

    def require_stimulus_triage
      redirect_to stimulus_filed_recently_path unless current_stimulus_triage.present?
    end

    def after_update_success; end

    def form_params
      params.fetch(form_name, {}).permit(*form_class.attribute_names)
    end

    def form_navigation
      @form_navigation ||= StimulusNavigation.new(self)
    end

    def tracking_data
      return {} unless @form.class.scoped_attributes.key?(:stimulus_triage)

      @form.attributes_for(:stimulus_triage)
    end

    class << self
      def form_class
        form_key.classify.constantize
      end

      def form_key
        "stimulus/" + controller_name + "_form"
      end

      def form_name
        form_key.gsub("/", "_")
      end

      def path_for(params)
        path_helper_string = [
                               "stimulus",
                               controller_name,
                               "path"
                             ].join("_") # "stimulus_controller_name_path"
        Rails.application.routes.url_helpers.send(path_helper_string, params)
      end
    end
  end
end
