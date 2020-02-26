module Questions
  class DivorcedYearController < QuestionsController
    layout "question"

    def section_title
      "Personal Information"
    end

    def self.show?(intake)
      intake.divorced_yes?
    end

    def illustration_path; end
  end
end
