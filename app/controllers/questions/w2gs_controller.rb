# frozen_string_literal: true

module Questions
  class W2gsController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.had_gambling_income_yes?
    end

    private

    def document_type
      "W-2G"
    end
  end
end
