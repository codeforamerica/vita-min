module StateFile
  module Questions
    class AzIncarceratedController < AuthenticatedQuestionsController
      include ReturnToReviewConcern

      def self.show?(intake)
        has_valid_ssn = intake.primary.ssn.present? && !intake.primary.has_itin?
        has_valid_agi = intake.direct_file_data.fed_agi <= (intake.filing_status_mfj? || intake.filing_status_hoh? ? 25_000 : 12_500)
        has_valid_ssn && has_valid_agi
      end
    end
  end
end
