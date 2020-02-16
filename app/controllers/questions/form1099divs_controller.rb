# frozen_string_literal: true

module Questions
  class Form1099divsController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.had_interest_income_yes?
    end

    private

    def document_type
      "1099-DIV"
    end
  end
end
