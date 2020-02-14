# frozen_string_literal: true

module Questions
  # Handles user uploads for Form student_account_statement's
  class FormStudentAccountStatementsController < DocumentUploadQuestionController
    def edit
      dependent_names = current_intake.dependents.where(was_student: "yes").map { |dependent| "#{dependent.first_name} #{dependent.last_name}" }.join(", ")
      @help_text = "Earlier, you told us that you are filing taxes for people who are full-time students. We need to verify this by seeing a student account statement.<br/>Please share an image of the student account statement for the following people: #{dependent_names}".html_safe
      super
    end

    private

    def document_type
      "student_account_statement"
    end
  end
end
