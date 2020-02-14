# frozen_string_literal: true

module Questions
  # Handles user uploads for Form 5498-SA's
  class Form5498sasController < DocumentUploadQuestionController

    private

    def document_type
      "5498-SA"
    end
  end
end
