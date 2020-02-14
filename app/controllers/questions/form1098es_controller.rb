# frozen_string_literal: true

module Questions
  # Handles user uploads for Form 1098-E's
  class Form1098esController < DocumentUploadQuestionController

    private

    def document_type
      "1098-E"
    end
  end
end
