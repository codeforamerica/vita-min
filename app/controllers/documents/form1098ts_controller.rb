module Documents
  class Form1098tsController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.had_student_in_family_yes?
    end
  end
end
