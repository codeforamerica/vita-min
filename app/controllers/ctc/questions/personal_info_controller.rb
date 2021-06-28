module Ctc
  module Questions
    class PersonalInfoController < QuestionsController
      include AnonymousIntakeConcern

      private

      def current_intake
        Intake::CtcIntake.new(visitor_id: cookies[:visitor_id])
      end

      def illustration_path; end

      def after_update_success
        session[:intake_id] = @form.intake.id
      end
    end
  end
end