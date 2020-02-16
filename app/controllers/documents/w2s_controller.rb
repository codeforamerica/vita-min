module Documents
  class W2sController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.had_wages_yes? ||
        intake.had_disability_income_yes? ||
        intake.had_a_job?
    end
  end
end
