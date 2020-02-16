module Documents
  class IraStatementsController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.paid_retirement_contributions_yes?
    end
  end
end
