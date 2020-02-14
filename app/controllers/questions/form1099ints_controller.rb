# frozen_string_literal: true

module Questions
  # Handles user uploads for Form 1099-INT's
  class Form1099intsController < DocumentUploadQuestionController

    private

    def document_type
      "1099-INT"
    end
  end
end
