# frozen_string_literal: true

module Questions
  class Form1099ssdisController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.had_disability_income_yes?
    end

    private

    def document_type
      "1099-SSDI"
    end
  end
end
