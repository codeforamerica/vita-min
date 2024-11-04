module StateFile
  module Questions
    class MdTwoIncomeSubtractionsController < QuestionsController

      def self.show?(intake)
        intake.filing_status_mfj?
      end

      def edit
        super
        @total_deduction = current_intake.direct_file_data.fed_student_loan_interest || 0
      end
      private
    end
  end
end



# Page appears conditionally if:
# Filing status = MFJ and
# StudentLoanInterestDedAmt (student loan interest) is present in DF XML
