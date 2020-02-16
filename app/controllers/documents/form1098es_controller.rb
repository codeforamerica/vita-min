module Documents
  class Form1098esController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.paid_student_loan_interest_yes?
    end
  end
end
