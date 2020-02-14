# frozen_string_literal: true

module Questions
  # Handles user uploads for Form 1099-DIV's
  class Form1099divsController < DocumentUploadQuestionController

    private

    def document_type
      "1099-DIV"
    end
  end
end
