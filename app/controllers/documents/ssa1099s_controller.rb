module Documents
  class Ssa1099sController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.had_social_security_income_yes?
    end
  end
end
