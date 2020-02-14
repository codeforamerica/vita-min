# frozen_string_literal: true

module Questions
  # Handles user uploads for Form IRA Statement's
  class IraStatementsController < DocumentUploadQuestionController

    private

    def document_type
      "IRA Statement"
    end
  end
end
