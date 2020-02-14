# frozen_string_literal: true

module Questions
  # Handles user uploads for Form 1099-G's
  class Form1099dashgsController < DocumentUploadQuestionController

    private

    def document_type
      "1099-G"
    end
  end
end
