module Ctc
  module Questions
    class AdvanceCtcClaimedController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        return false if intake.advance_ctc_amount_received.nil? || intake.dependents.count(&:qualifying_ctc?).zero?

        benefits = Efile::BenefitsEligibility.new(tax_return: intake.default_tax_return, dependents: intake.dependents)
        benefits.advance_ctc_amount_received >= benefits.ctc_amount
      end

      private

      def illustration_path
        "warning-triangle-yellow.svg"
      end

      def next_path
        case @form.advance_ctc_claimed_choice
        when "change_amount"
          questions_advance_ctc_amount_path
        when "dont_file"
          questions_not_filing_path
        when "add_dependents"
          questions_confirm_dependents_path
        else
          super
        end
      end

    end
  end
end
