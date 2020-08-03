module Documents
  class StudentAccountStatementsController < DocumentUploadQuestionController
    before_action :set_student_names, only: [:edit, :update]

    def self.document_type
      DocumentTypes::StudentAccountStatement
    end

    private

    def set_student_names
      @student_names = current_intake.student_names
    end
  end
end
