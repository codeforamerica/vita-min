module Documents
  class Form1099divsController < DocumentUploadQuestionController
    DOCUMENT_TYPE = '1099-DIV'.freeze

    def self.show?(intake)
      intake.had_interest_income_yes?
    end
  end
end
