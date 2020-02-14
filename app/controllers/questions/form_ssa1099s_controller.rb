# frozen_string_literal: true

module Questions
  # Handles user uploads for Form SSA-1099's
  class FormSsa1099sController < DocumentUploadQuestionController

    private

    def document_type
      "SSA-1099"
    end
  end
end
