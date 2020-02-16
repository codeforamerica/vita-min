# frozen_string_literal: true

module Questions
  class Form1099rsController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.had_retirement_income_yes?
    end

    private

    def document_type
      "1099-R"
    end
  end
end
