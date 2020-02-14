# frozen_string_literal: true

module Questions
  # Handles user uploads for Form RRB-1099's
  class FormRrb1099sController < DocumentUploadQuestionController

    private

    def document_type
      "RRB-1099"
    end
  end
end
