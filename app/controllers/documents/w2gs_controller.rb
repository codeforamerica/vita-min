module Documents
  class W2gsController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.had_gambling_income_yes?
    end

    def self.document_type
      "W-2G"
    end
  end
end
