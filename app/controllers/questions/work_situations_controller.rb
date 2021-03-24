module Questions
  class WorkSituationsController < AuthenticatedIntakeController
    def illustration_path
      "job-count.svg"
    end
  end
end