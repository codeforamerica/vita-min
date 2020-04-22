module Documents
  class Rrb1099sController < DocumentUploadQuestionController
    DOCUMENT_TYPE = 'RRB-1098'.freeze

    def self.show?(intake)
      intake.had_social_security_income_yes?
    end
  end
end
