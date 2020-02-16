module Documents
  class Form1099rsController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.had_retirement_income_yes?
    end
  end
end
