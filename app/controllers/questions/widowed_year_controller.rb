module Questions
  class WidowedYearController < QuestionsController
    layout "question"

    def section_title
      "Personal Information"
    end

    def self.show?(intake)
      intake.married_no? && (
        intake.widowed_yes? || intake.widowed_unfilled?
      )
    end
  end
end