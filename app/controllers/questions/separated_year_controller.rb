module Questions
  class SeparatedYearController < QuestionsController
    layout "question"

    def section_title
      "Personal Information"
    end

    def self.show?(intake)
      intake.separated_yes?
    end

    def illustration_path; end
  end
end
