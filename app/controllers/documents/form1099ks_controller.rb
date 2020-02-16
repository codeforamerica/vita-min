module Documents
  class Form1099ksController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.had_self_employment_income_yes?
    end
  end
end
