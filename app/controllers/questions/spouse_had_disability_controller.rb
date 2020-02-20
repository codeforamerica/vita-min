module Questions
  class SpouseHadDisabilityController < QuestionsController
    layout "yes_no_question"

    def self.show?(intake)
      intake.filing_joint_yes?
    end

    def section_title
      "Personal Information"
    end

    def illustration_path
      "had-disability.svg"
    end
  end
end