module Documents
  class Form1099divsController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.had_interest_income_yes?
    end

    def self.document_type
      "1099-DIV"
    end
  end
end
