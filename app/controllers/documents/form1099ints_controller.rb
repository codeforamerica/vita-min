module Documents
  class Form1099intsController < DocumentUploadQuestionController
    DOCUMENT_TYPE = '1099-INT'.freeze

    def self.show?(intake)
      intake.had_interest_income_yes?
    end
  end
end
