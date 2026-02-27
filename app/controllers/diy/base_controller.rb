module Diy
  class BaseController < ApplicationController
    before_action :redirect_in_offseason

    def current_diy_intake
      if session[:diy_intake_id]
        DiyIntake.find(session[:diy_intake_id])
      else
        DiyIntake.new(preferred_first_name: "temp")
      end
    end

    private

    def after_update_success; end

    def after_update_failure; end

    def require_diy_intake
      redirect_to diy_qualifications_path unless session[:diy_intake_id].present?
    end

    def redirect_in_offseason
      redirect_to root_path unless open_for_diy?
    end

    def track_question_answer
      send_mixpanel_event(event_name: "question_answered", data: tracking_data)
    end

    def track_validation_error
      send_mixpanel_validation_error(@form.errors, tracking_data)
    end

    def tracking_data
      return {} unless @form.class.scoped_attributes.key?(:diy_intake)

      @form.attributes_for(:diy_intake).except(*Rails.application.config.filter_parameters)
    end
  end
end
