# frozen_string_literal: true

module Questions
  class Form1099ksController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.had_self_employment_income_yes?
    end

    private

    def document_type
      "1099-K"
    end
  end
end
