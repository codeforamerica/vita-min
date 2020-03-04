module Documents
  class StudentAccountStatementsController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.had_student_in_family_yes?
    end

    def edit
      @student_names = current_intake.student_names
      super
    end
  end
end
