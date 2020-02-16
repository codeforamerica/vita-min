# frozen_string_literal: true

module Questions
  class Form1098esController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.paid_student_loan_interest_yes?
    end

    private

    def document_type
      "1098-E"
    end
  end
end
