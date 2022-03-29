module Ctc
  module Questions
    class AdvanceCtcReceivedController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        return false if intake.advance_ctc_amount_received.nil?

        benefits = Efile::BenefitsEligibility.new(tax_return: intake.default_tax_return, dependents: intake.dependents)
        benefits.advance_ctc_amount_received < benefits.outstanding_ctc_amount
      end

      def edit
        benefits = Efile::BenefitsEligibility.new(tax_return: current_intake.default_tax_return, dependents: current_intake.dependents)
        @ctc_owed = benefits.outstanding_ctc_amount
        super
      end

      private

      def illustration_path; end

      def initialized_edit_form
        nil
      end
    end
  end
end
