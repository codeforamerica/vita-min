module StateFile
  module Questions
    class TaxBreakEvenController < QuestionsController
      def self.show?(intake)
        intake.calculated_refund_or_owed_amount.zero?
      end
    end
  end
end
