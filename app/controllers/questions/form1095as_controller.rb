# frozen_string_literal: true

module Questions
  # Handles user uploads for Form 1095-A's
  class Form1095asController < DocumentUploadQuestionController

    private

    def document_type
      "1095-A"
    end
  end
end
