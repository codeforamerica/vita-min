module Questions
  class FilingJointController < QuestionsController
    layout "yes_no_question"

    def self.show?(intake)
      intake.married_yes?
    end

    def section_title
      "Personal Information"
    end
  end
end