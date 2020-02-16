module Documents
  class Form1099divsController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.had_interest_income_yes?
    end
  end
end
