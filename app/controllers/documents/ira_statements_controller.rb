module Documents
  class IraStatementsController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.paid_retirement_contributions_yes?
    end

    def self.document_type
      "IRA Statement"
    end
  end
end
