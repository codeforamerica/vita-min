module Documents
  class Form1099miscsController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.had_self_employment_income_yes? ||
        intake.had_a_job?
    end

    def self.document_type
      "1099-MISC"
    end
  end
end
