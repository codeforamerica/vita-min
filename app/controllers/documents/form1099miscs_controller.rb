module Documents
  class Form1099miscsController < DocumentUploadQuestionController
    DOCUMENT_TYPE = '1099-MISC'.freeze

    def self.show?(intake)
      intake.had_self_employment_income_yes? ||
        intake.had_a_job?
    end
  end
end
