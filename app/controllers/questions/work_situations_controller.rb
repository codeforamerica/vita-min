module Questions
  class WorkSituationsController < QuestionsController
    def self.show?(intake)
      intake.had_a_job?
    end

    def illustration_path
      "job-count.svg"
    end
  end
end