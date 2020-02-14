# frozen_string_literal: true

module Questions
  # Handles user uploads for Form 1099-R's
  class Form1099rsController < DocumentUploadQuestionController

    private

    def document_type
      "1099-R"
    end
  end
end
