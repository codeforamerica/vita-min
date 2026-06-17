module Questions
  class EligibilityHouseholdController < QuestionsController
    include AnonymousIntakeConcern

    layout "intake"

    def edit; end

    def next_path
      TriageResultService.new(current_intake).after_income_levels_triaged_route || super
    end

    def illustration_path; end
  end
end