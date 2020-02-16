# frozen_string_literal: true

module Questions
  class Form1099asController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.had_debt_forgiven_yes?
    end

    private

    def document_type
      "1099-A"
    end
  end
end
