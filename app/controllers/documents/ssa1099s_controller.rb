module Documents
  class Ssa1099sController < DocumentUploadQuestionController
    DOCUMENT_TYPE = 'SSA-1099'.freeze

    def self.show?(intake)
      intake.had_social_security_income_yes?
    end
  end
end
