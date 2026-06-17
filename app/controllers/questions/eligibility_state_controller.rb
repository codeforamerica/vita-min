module Questions
  class EligibilityStateController < QuestionsController
    include AnonymousIntakeConcern

    layout "intake"

    # remove this?
    # def next_path
    #   TriageResultService.new(current_intake).after_income_levels_triaged_route || super
    # end

    def illustration_path; end
  end
end
