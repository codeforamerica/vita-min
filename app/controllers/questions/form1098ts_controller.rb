# frozen_string_literal: true

module Questions
  # Handles user uploads for Form 1098-T's
  class Form1098tsController < DocumentUploadQuestionController

    private

    def document_type
      "1098-T"
    end
  end
end
