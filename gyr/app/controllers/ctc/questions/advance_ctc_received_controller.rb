module Ctc
  module Questions
    class AdvanceCtcReceivedController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        return false if intake.advance_ctc_amount_received.nil? || intake.dependents.count(&:qualifying_ctc?).zero?

        benefits = Efile::BenefitsEligibility.new(tax_return: intake.default_tax_return, dependents: intake.dependents)
        benefits.advance_ctc_amount_received < benefits.ctc_amount
      end

      def edit
        benefits = Efile::BenefitsEligibility.new(tax_return: current_intake.default_tax_return, dependents: current_intake.dependents)
        @ctc_owed = benefits.outstanding_ctc_amount
        super
      end

      private

      def illustration_path; end

      def form_class
        NullForm
      end
    end
  end
end
