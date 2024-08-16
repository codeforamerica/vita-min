module StateFile
  module Questions
    class AzRetirementIncomeController < QuestionsController
      include ReturnToReviewConcern

      def edit
        puts current_intake.filing_status_mfj?
        puts "CONTROLLER #{current_intake.id}"
        @attributes = [:received_military_retirement_payment, :primary_received_pension]
        @attributes << :spouse_received_pension if current_intake.filing_status_mfj?
        super
      end

      def self.show?(intake)
        intake.direct_file_data.form1099rs.length > 0 &&
          intake.direct_file_data.fed_taxable_pensions > 0
      end
    end
  end
end
