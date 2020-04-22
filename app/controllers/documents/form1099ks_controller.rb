module Documents
  class Form1099ksController < DocumentUploadQuestionController
    DOCUMENT_TYPE = '1099-K'.freeze

    def self.show?(intake)
      intake.had_self_employment_income_yes?
    end
  end
end
