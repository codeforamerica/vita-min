# frozen_string_literal: true

module Questions
  # Handles user uploads for Form 1099-S's
  class Form1099ssController < DocumentUploadQuestionController

    private

    def document_type
      "1099-S"
    end
  end
end
