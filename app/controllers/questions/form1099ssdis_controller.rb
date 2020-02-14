# frozen_string_literal: true

module Questions
  # Handles user uploads for Form 1099-SSDI's
  class Form1099ssdisController < DocumentUploadQuestionController

    private

    def document_type
      "1099-SSDI"
    end
  end
end
