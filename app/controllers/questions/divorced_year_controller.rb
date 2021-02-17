module Questions
  class DivorcedYearController < QuestionsController
    layout "intake"

    def self.show?(intake)
      intake.divorced_yes?
    end

    def illustration_path; end
  end
end
