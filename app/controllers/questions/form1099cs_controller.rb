# frozen_string_literal: true

module Questions
  # Handles user uploads for Form 1099-C's
  class Form1099csController < DocumentUploadQuestionController

    private

    def document_type
      "1099-C"
    end
  end
end
