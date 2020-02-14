# frozen_string_literal: true

module Questions
  # Handles user uploads for Form IraStatement's
  class FormIrastatementsController < DocumentUploadQuestionController

    private

    def document_type
      "IraStatement"
    end
  end
end
