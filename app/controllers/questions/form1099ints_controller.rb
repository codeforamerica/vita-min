# frozen_string_literal: true

module Questions
  class Form1099intsController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.had_interest_income_yes?
    end

    private

    def document_type
      "1099-INT"
    end
  end
end
