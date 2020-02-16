module Documents
  class Form1099ssdisController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.had_disability_income_yes?
    end
  end
end
