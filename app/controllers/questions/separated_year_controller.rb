module Questions
  class SeparatedYearController < QuestionsController
    layout "question"

    def section_title
      "Personal Information"
    end

    def self.show?(intake)
      intake.married_yes? && (
        intake.separated_yes? || intake.separated_unfilled?
      )
    end

    def no_illustration?
      true
    end
  end
end