# frozen_string_literal: true

module Questions
  class FormChildcareStatementsController < DocumentUploadQuestionController

    private

    def document_type
      "childcare_statement"
    end
  end
end
