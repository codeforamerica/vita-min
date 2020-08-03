module Documents
  class StudentAccountStatementsController < DocumentUploadQuestionController
    before_action :set_student_names, only: [:edit, :update]

    def self.show?(intake)
      intake.any_students?
    end

    def self.document_type
      "Student Account Statement"
    end

    private

    def set_student_names
      @student_names = current_intake.student_names
    end
  end
end
