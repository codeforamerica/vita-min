# frozen_string_literal: true

module Questions
  # Handles user uploads for Form SSN or ITIN's
  class SsnItinsController < DocumentUploadQuestionController
    def edit
      dependent_names = current_intake.dependents.map { |dependent| "#{dependent.first_name} #{dependent.last_name}" }.join(", ")
      @help_text = "Earlier, you told us that you have dependents. We need to verify this by seeing a Social Security Card or ITIN Paperwork.<br/>Please share an image of a Social Security Card or ITIN Paperwork for these dependents: #{dependent_names}".html_safe
      super
    end

    private

    def document_type
      "SSN or ITIN"
    end
  end
end
