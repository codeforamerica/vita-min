module StateFile
  module Questions
    class AzRetirementIncomeController < QuestionsController
      include ReturnToReviewConcern

      def self.show?(intake)
        intake.direct_file_data.form1099rs.length > 0 &&
          intake.direct_file_data.fed_taxable_pensions > 0
      end
    end
  end
end
