module Questions
  class QuestionsController < ApplicationController
    before_action :require_sign_in

    delegate :form_name, to: :class
    delegate :form_class, to: :class

    helper_method :current_path
    helper_method :section_title
    helper_method :illustration_path
    helper_method :next_path

    layout "question"

    def edit
      @form = form_class.from_intake(current_intake)
    end

    def update
      @form = form_class.new(current_intake, form_params)
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

    def next_path(params = {})
      next_step = form_navigation.next
      question_path(next_step.to_param, params) if next_step
    end

    def section_title; end

    def illustration_path
      controller_name.dasherize + ".svg"
    end

    def self.show?(intake)
      true
    end

    private

    def after_update_success; end

    def require_intake
      return redirect_to question_path(QuestionNavigation.first) unless current_intake.present?
    end

    def form_params
      params.fetch(form_name, {}).permit(*form_class.attribute_names)
    end

    def form_navigation
      @form_navigation ||= QuestionNavigation.new(self)
    end

    def track_question_answer
      send_mixpanel_event(event_name: "question_answered", data: tracking_data)
    end

    def track_validation_error
      send_mixpanel_validation_error(@form.errors, tracking_data)
    end

    def tracking_data
      return {} unless @form.class.scoped_attributes.key?(:intake)

      @form.attributes_for(:intake)
    end

    class << self
      def to_param
        controller_name.dasherize
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
