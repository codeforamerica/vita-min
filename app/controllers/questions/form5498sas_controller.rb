# frozen_string_literal: true

module Questions
  class Form5498sasController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.had_hsa_yes?
    end

    private

    def document_type
      "5498-SA"
    end
  end
end
