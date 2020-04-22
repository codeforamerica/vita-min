module Documents
  class Form1098esController < DocumentUploadQuestionController
    DOCUMENT_TYPE = '1098-E'

    def self.show?(intake)
      intake.paid_student_loan_interest_yes?
    end
  end
end
