# frozen_string_literal: true

module Questions
  # Handles user uploads for Form 1099-SA's
  class Form1099sasController < DocumentUploadQuestionController

    private

    def document_type
      "1099-SA"
    end
  end
end
