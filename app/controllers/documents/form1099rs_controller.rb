module Documents
  class Form1099rsController < DocumentUploadQuestionController
    DOCUMENT_TYPE = '1099-R'.freeze

    def self.show?(intake)
      intake.had_retirement_income_yes?
    end
  end
end
