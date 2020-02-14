# frozen_string_literal: true

module Questions
  # Handles user uploads for Form 1099-K's
  class Form1099ksController < DocumentUploadQuestionController

    private

    def document_type
      "1099-K"
    end
  end
end
