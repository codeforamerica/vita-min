# frozen_string_literal: true

module Questions
  # Handles user uploads for Form W-2G's
  class FormW2gsController < DocumentUploadQuestionController

    private

    def document_type
      "W-2G"
    end
  end
end
