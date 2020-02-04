module Questions
  class FilingJointController < QuestionsController
    layout "yes_no_question"

    def self.show?(intake)
      intake.married_yes? || intake.married_unfilled?
    end

    def section_title
      "Personal Information"
    end
  end
end