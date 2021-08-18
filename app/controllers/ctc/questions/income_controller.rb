module Ctc
  module Questions
    class IncomeController < QuestionsController
      include AnonymousIntakeConcern

      layout "yes_no_question"

      def update
        current_capacity = CtcIntakeCapacity.last&.capacity
        if !current_capacity.nil? && EfileSubmission.where("created_at > ?", Date.today.beginning_of_day).count >= current_capacity
          return redirect_to questions_at_capacity_path
        end

        super
      end

      private

      def form_params
        super.merge(ip_address: request.remote_ip).merge(
          Rails.application.config.try(:efile_security_information_for_testing).presence || {}
        )
      end

      def after_update_success
        session[:intake_id] = current_intake.id
      end

      def after_update_failure
        if Set.new(@form.errors.keys).intersect?(Set.new(@form.class.scoped_attributes[:efile_security_information]))
          flash[:alert] = I18n.t("general.enable_javascript")
        end
      end

      def current_intake
        @intake ||= Intake::CtcIntake.new(visitor_id: cookies[:visitor_id], source: session[:source])
      end

      def method_name
        "had_reportable_income"
      end

      def illustration_path
        "hand-holding-check.svg"
      end

      def next_path
        @form.had_reportable_income? ? questions_use_gyr_path : super
      end

      def tracking_data
        @form.attributes_for(:misc)
      end
    end
  end
end
