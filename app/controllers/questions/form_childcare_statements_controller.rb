# frozen_string_literal: true

module Questions
  # Handles user uploads for Form childcare_statement's
  class FormChildcareStatementsController < DocumentUploadQuestionController

    private

    def document_type
      "childcare_statement"
    end
  end
end
