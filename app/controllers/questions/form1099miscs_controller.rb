# frozen_string_literal: true

module Questions
  # Handles user uploads for Form 1099-MISC's
  class Form1099miscsController < DocumentUploadQuestionController

    private

    def document_type
      "1099-MISC"
    end
  end
end
