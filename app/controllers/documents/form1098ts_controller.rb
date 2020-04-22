module Documents
  class Form1098tsController < DocumentUploadQuestionController
    DOCUMENT_TYPE = '1098-T'

    def self.show?(intake)
      intake.had_student_in_family_yes?
    end
  end
end
