module Documents
  class Form1099gsController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.had_unemployment_income_yes?
    end
  end
end
