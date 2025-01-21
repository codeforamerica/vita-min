module StateFile
  module Questions
    class MdSocialSecurityBenefitsController < BaseReviewController
      def self.show?(intake)
        intake.filing_status_mfj? && intake.direct_file_data.fed_student_loan_interest.present?
      end

      def edit
        super
        @total_deduction = current_intake.direct_file_data.fed_student_loan_interest || 0
      end
    end
  end
end
