module StateFile
  module Questions
    class AzRetirementIncomeController < QuestionsController
      before_action :load_attributes, only: [:edit, :update]
      include ReturnToReviewConcern

      def self.show?(intake)
        intake.direct_file_data.form1099rs.length > 0 &&
          intake.direct_file_data.fed_taxable_pensions > 0
      end

      private

      def load_attributes
        @attributes = [:received_military_retirement_payment, :primary_received_pension]
        @attributes << :spouse_received_pension if current_intake.filing_status_mfj?
      end
    end
  end
end
