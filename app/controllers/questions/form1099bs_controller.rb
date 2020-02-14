# frozen_string_literal: true

module Questions
  # Handles user uploads for Form 1099-B's
  class Form1099bsController < DocumentUploadQuestionController

    private

    def document_type
      "1099-B"
    end
  end
end
