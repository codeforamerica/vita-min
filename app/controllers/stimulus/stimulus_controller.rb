module Stimulus
  class StimulusController < ApplicationController
    delegate :form_name, to: :class
    delegate :form_class, to: :class

    helper_method :current_path
    helper_method :illustration_folder
    helper_method :illustration_path
    helper_method :next_path

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
      polymorphic_path([:stimulus, controller_name], params)
    end

    def next_path(params = {})
      next_step = form_navigation.next
      polymorphic_path([:stimulus, next_step.controller_name], params) if next_step
    end

    def illustration_folder
      "stimulus"
    end

    def illustration_path
      "#{controller_name.dasherize}.svg"
    end

     def self.show?(intake)
       true
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

    def track_validation_error
      send_mixpanel_validation_error(@form.errors, tracking_data)
    end

    def tracking_data
      return {} unless @form.class.scoped_attributes.key?(:stimulus_triage)

      @form.attributes_for(:stimulus_triage)
    end

    class << self
      def to_param
        controller_name.dasherize
      end

      def form_name
        "stimulus/" + controller_name + "_form"
      end

      def form_class
        form_name.classify.constantize
      end
    end
  end
end
