module Questions
  class DivorcedYearController < QuestionsController
    layout "question"

    def section_title
      "Personal Information"
    end

    def self.show?(intake)
      intake.married_no? && (
        intake.divorced_yes? || intake.divorced_unfilled?
      )
    end

    def no_illustration?
      true
    end
  end
end