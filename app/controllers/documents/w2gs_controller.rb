module Documents
  class W2gsController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.had_gambling_income_yes?
    end
  end
end
