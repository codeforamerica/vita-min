module Documents
  class W2gsController < DocumentUploadQuestionController
    DOCUMENT_TYPE = 'W-2G'.freeze

    def self.show?(intake)
      intake.had_gambling_income_yes?
    end
  end
end
