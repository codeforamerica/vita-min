# frozen_string_literal: true

module Questions
  # Handles user uploads for Form 2018 Tax Return's
  class PriorTaxReturnsController < DocumentUploadQuestionController

    private

    def document_type
      "2018 Tax Return"
    end
  end
end
