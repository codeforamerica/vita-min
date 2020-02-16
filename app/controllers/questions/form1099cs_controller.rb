# frozen_string_literal: true

module Questions
  class Form1099csController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.had_debt_forgiven_yes?
    end

    private

    def document_type
      "1099-C"
    end
  end
end
