module Questions
  class SpouseWasStudentController < QuestionsController
    layout "yes_no_question"

    def self.show?(intake)
      intake.filing_joint_yes?
    end

    def illustration_path
      "was-student.svg"
    end
  end
end