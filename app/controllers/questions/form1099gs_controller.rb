# frozen_string_literal: true

module Questions
  # Handles user uploads for Form 1099G's
  class Form1099gsController < DocumentUploadQuestionController

    private

    def document_type
      "1099G"
    end
  end
end
