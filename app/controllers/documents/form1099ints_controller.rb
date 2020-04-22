module Documents
  class Form1099intsController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.had_interest_income_yes?
    end

    def self.document_type
      "1099-INT"
    end
  end
end
