# frozen_string_literal: true

module Questions
  # Handles user uploads for Form 1099-A's
  class Form1099asController < DocumentUploadQuestionController

    private

    def document_type
      "1099-A"
    end
  end
end
