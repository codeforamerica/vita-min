module Documents
  class ChildcareStatementsController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.paid_dependent_care_yes?
    end
  end
end
