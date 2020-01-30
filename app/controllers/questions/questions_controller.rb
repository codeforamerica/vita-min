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
        update_session
        redirect_to(next_path)
      else
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
      ""
    end

    def self.show?(intake)
      true
    end

    private

    def require_sign_in
      unless user_signed_in?
        redirect_to identity_questions_path
      end
    end

    def update_session
    end

    def form_params
      params.fetch(form_name, {}).permit(*form_class.attribute_names)
    end

    def form_navigation
      @form_navigation ||= QuestionNavigation.new(self)
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