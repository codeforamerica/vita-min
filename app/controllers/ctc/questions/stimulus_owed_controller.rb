module Ctc
  module Questions
    class StimulusOwedController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        intake.tax_return(2020).outstanding_recovery_rebate_amount > 0
      end

      def edit
        @outstanding_credit = current_intake.tax_return(2020).outstanding_recovery_rebate_amount
        super
      end

      private

      def illustration_path; end
    end
  end
end