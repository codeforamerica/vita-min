module Ctc
  module Questions
    class W2sController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        return unless Flipper.enabled?(:eitc)

        benefits_eligibility = Efile::BenefitsEligibility.new(tax_return: intake.default_tax_return, dependents: intake.dependents)
        benefits_eligibility.claiming_and_qualified_for_eitc?
      end

      def next_path
        if current_intake.had_w2s_yes?
          Ctc::Questions::W2s::EmployeeInfoController.to_path_helper(id: current_intake.new_record_token)
        elsif current_intake.had_w2s_no?
          form_navigation.next(Ctc::Questions::ConfirmW2sController).to_path_helper
        end
      end

      private

      def illustration_path; end
    end
  end
end
