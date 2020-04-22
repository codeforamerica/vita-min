module Documents
  class W2sController < DocumentUploadQuestionController
    DOCUMENT_TYPE = 'W-2'.freeze

    def self.show?(intake)
      intake.had_wages_yes? ||
        intake.had_disability_income_yes? ||
        intake.had_a_job?
    end
  end
end
