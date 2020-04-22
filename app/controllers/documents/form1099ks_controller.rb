module Documents
  class Form1099ksController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.had_self_employment_income_yes?
    end

    def self.document_type
      "1099-K"
    end
  end
end
