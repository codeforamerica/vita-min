module Ctc
  module Questions
    class EitcNoW2OffboardingController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake, current_controller)
        return unless current_controller.open_for_eitc_intake?

        intake.had_w2s_no? || intake.w2s.none?
      end

      def next_path
        if current_intake.had_w2s_yes?
          Ctc::Questions::W2s::EmployeeInfoController.to_path_helper(id: current_intake.new_record_token)
        else
          super
        end
      end

      private

      def illustration_path
        "error.svg"
      end

      def form_class
        W2sForm
      end

      def form_name
        "ctc_w2s_form"
      end
    end
  end
end
