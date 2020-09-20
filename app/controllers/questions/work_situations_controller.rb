module Questions
  class WorkSituationsController < QuestionsController
    def self.show?(intake)
      intake.had_a_job?
    end
  end
end