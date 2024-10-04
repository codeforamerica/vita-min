module StateFile
  module Questions
    class NjDisabledExemptionController < QuestionsController
      include ReturnToReviewConcern

      before_action -> { @filing_year = Rails.configuration.statefile_current_tax_year }

      def self.show?(intake)
        if intake.filing_status_mfj?
          !intake.direct_file_data.is_primary_blind? || !intake.direct_file_data.is_spouse_blind?
        else
          !intake.direct_file_data.is_primary_blind?
        end
      end
    end
  end
end