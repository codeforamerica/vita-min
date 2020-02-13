module Questions
  class FilingJointController < QuestionsController
    layout "yes_no_question"

    def section_title
      "Personal Information"
    end

    def self.show?(intake)
      intake.ever_married_yes?
    end

    def no_illustration?
      true
    end
  end
end