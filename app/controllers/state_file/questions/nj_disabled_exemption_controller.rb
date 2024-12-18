module StateFile
  module Questions
    class NjDisabledExemptionController < QuestionsController
      include ReturnToReviewConcern

      def self.show?(intake)
        self.potential_unclaimed_disability_exemption?(intake)
      end

      def self.potential_unclaimed_disability_exemption?(intake)
        if intake.filing_status_mfj?
          return false if intake.direct_file_data.is_primary_blind? && intake.direct_file_data.is_spouse_blind?
        elsif intake.direct_file_data.is_primary_blind?
          return false
        end 
        true
      end
    end
  end
end