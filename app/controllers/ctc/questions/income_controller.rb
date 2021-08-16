module Ctc
  module Questions
    class IncomeController < QuestionsController
      include AnonymousIntakeConcern
      layout "yes_no_question"

      def update
        super
        session[:intake_id] = current_intake.id
      end

      private

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
