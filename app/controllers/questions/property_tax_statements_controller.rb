# frozen_string_literal: true

module Questions
  # Handles user uploads for Form PropertyTaxStatement's
  class PropertyTaxStatementsController < DocumentUploadQuestionController

    private

    def document_type
      "Property Tax Statement"
    end
  end
end
