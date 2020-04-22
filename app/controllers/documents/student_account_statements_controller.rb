module Documents
  class StudentAccountStatementsController < DocumentUploadQuestionController
    DOCUMENT_TYPE = 'Student Account Statement'.freeze

    def self.show?(intake)
      intake.any_students?
    end

    def edit
      @student_names = current_intake.student_names
      super
    end
  end
end
