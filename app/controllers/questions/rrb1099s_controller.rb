# frozen_string_literal: true

module Questions
  class Rrb1099sController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.had_social_security_income_yes?
    end

    private

    def document_type
      "RRB-1099"
    end
  end
end
