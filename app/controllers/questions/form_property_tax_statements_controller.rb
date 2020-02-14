# frozen_string_literal: true

module Questions
  # Handles user uploads for Form PropertyTaxStatement's
  class FormPropertyTaxStatementsController < DocumentUploadQuestionController

    private

    def document_type
      "property_tax_statement"
    end
  end
end
