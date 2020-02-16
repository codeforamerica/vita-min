# frozen_string_literal: true

module Questions
  class Form1099sasController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.had_hsa_yes?
    end

    private

    def document_type
      "1099-SA"
    end
  end
end
