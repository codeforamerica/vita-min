module Documents
  class StudentAccountStatementsController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.had_student_in_family_yes?
    end

    def edit
      dependent_names = current_intake.dependents.where(was_student: "yes").map { |dependent| "#{dependent.first_name} #{dependent.last_name}" }.join(", ")
      @help_text = "Earlier, you told us that you are filing taxes for people who are full-time students. We need to verify this by seeing a student account statement.<br/>Please share an image of the student account statement for the following people: #{dependent_names}".html_safe
      super
    end
  end
end
