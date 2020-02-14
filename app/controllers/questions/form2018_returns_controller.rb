# frozen_string_literal: true

module Questions
  # Handles user uploads for Form 2018_return's
  class Form2018ReturnsController < DocumentUploadQuestionController

    private

    def document_type
      "2018_return"
    end
  end
end
