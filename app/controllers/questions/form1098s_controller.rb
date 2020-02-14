# frozen_string_literal: true

module Questions
  # Handles user uploads for Form 1098's
  class Form1098sController < DocumentUploadQuestionController

    private

    def document_type
      "1098"
    end
  end
end
