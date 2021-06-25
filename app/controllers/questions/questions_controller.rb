module Questions
  class QuestionsController < ApplicationController
    before_action :set_current_step

    delegate :form_name, to: :class
    delegate :form_class, to: :class

    helper_method :current_path, :illustration_folder, :illustration_path, :next_path, :prev_path, :has_unsure_option?, :method_name

    layout "intake"

    def edit
      @form = form_class.from_intake(current_intake)
    end

    def update
      @form = initialized_update_form
      if @form.valid?
        @form.save
        after_update_success
        track_question_answer
        redirect_to(next_path)
      else
        track_validation_error
        render :edit
      end
    end

    def current_path(params = {})
      question_path(self.class.to_param, params)
    end

    def next_path
      next_step = form_navigation.next
      next_step&.to_path_helper
    end

    def prev_path
      prev_step = form_navigation&.prev
      prev_step&.to_path_helper
    end

    def has_unsure_option?
      layout = self.send :_layout, self.lookup_context, [""]
      return false unless layout == "yes_no_question"
      enum_options = parent_class.try(method_name.pluralize)
      enum_options&.has_key?("unsure")
    end

    def parent_class
      Intake
    end

    def method_name
      controller_name
    end

    def illustration_folder
      "questions"
    end

    def illustration_path
      controller_name.dasherize + ".svg"
    end

    def self.show?(intake)
      true
    end

    def show_progress?
      IntakeProgressCalculator.show_progress?(self.class)
    end

    def form_navigation
      QuestionNavigation.new(self)
    end

    private

    def after_update_success; end

    # Overwrite in order to change which record or params are passed to the form during update
    def initialized_update_form
      form_class.new(current_intake, form_params)
    end

    def form_params
      params.fetch(form_name, {}).permit(*form_class.attribute_names)
    end

    def track_question_answer
      send_mixpanel_event(event_name: "question_answered", data: tracking_data)
    end

    def track_validation_error
      send_mixpanel_validation_error(@form.errors, tracking_data)
    end

    def tracking_data
      return {} unless @form.class.scoped_attributes.key?(:intake)

      @form.attributes_for(:intake).except(*Rails.application.config.filter_parameters)
    end

    class << self
      def to_param
        controller_name.dasherize
      end

      def to_path_helper
        path_helper_string = [
          controller_name,
          module_parent.name.underscore,
          "path"
        ].join("_") # "controller_name_module_path"

        # Pass default_url_options (namely, locale) from ApplicationController when computing URL for this controller
        Rails.application.routes.url_helpers.send(path_helper_string.to_sym, default_url_options)
      end

      def form_name
        controller_name + "_form"
      end

      def form_class
        form_name.classify.constantize
      end
    end
  end
end
