module Documents
  class Form1099gsController < DocumentUploadQuestionController
    DOCUMENT_TYPE = '1099-G'.freeze

    def self.show?(intake)
      intake.had_unemployment_income_yes?
    end
  end
end
