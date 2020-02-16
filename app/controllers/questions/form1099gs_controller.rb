# frozen_string_literal: true

module Questions
  class Form1099gsController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.had_unemployment_income_yes?
    end

    private

    def document_type
      "1099-G"
    end
  end
end
