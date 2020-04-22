module Documents
  class IraStatementsController < DocumentUploadQuestionController
    DOCUMENT_TYPE = 'IRA Statement'.freeze

    def self.show?(intake)
      intake.paid_retirement_contributions_yes?
    end
  end
end
