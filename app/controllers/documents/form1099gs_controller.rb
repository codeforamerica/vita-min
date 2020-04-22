module Documents
  class Form1099gsController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.had_unemployment_income_yes?
    end

    def self.document_type
      "1099-G"
    end
  end
end
