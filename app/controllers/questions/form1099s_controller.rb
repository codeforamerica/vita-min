# frozen_string_literal: true

module Questions
  # Handles user uploads for Form 1099's
  class Form1099sController < DocumentUploadQuestionController

    private

    def document_type
      "1099"
    end
  end
end
