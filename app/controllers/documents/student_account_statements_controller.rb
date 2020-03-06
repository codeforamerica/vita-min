module Documents
  class StudentAccountStatementsController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.any_students?
    end

    def edit
      @student_names = current_intake.student_names
      super
    end
  end
end
