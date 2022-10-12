module Ctc
  module Questions
    class W2sController < QuestionsController
      include AuthenticatedCtcClientConcern

      before_action :track_w2s_list_first_visit, only: :edit

      layout "intake"

      def self.show?(intake, current_controller)
        return unless current_controller.open_for_eitc_intake?

        benefits_eligibility = Efile::BenefitsEligibility.new(tax_return: intake.default_tax_return, dependents: intake.dependents)
        benefits_eligibility.claiming_and_qualified_for_eitc_pre_w2s?
      end

      def edit
        set_done_adding_path
      end

      def add_w2_later
        track_first_visit(:w2_logout_add_later)

        clear_intake_session
        redirect_to root_path
      end

      def next_path
        if current_intake.had_w2s_yes?
          Ctc::Questions::W2s::EmployeeInfoController.to_path_helper(id: current_intake.new_record_token)
        elsif current_intake.had_w2s_no?
          form_navigation.next(Ctc::Questions::ConfirmW2sController).to_path_helper
        end
      end

      def set_done_adding_path
        @done_adding_path =
          if current_intake.benefits_eligibility.disqualified_for_simplified_filing_due_to_w2_answers?
            Ctc::Questions::UseGyrController.to_path_helper
          else
            form_navigation.next(Ctc::Questions::ConfirmW2sController).to_path_helper
          end
      end

      private

      def track_w2s_list_first_visit
        track_first_visit(:w2s_list)
      end

      def illustration_path; end
    end
  end
end
