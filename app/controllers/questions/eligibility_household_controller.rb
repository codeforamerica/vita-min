module Questions
  class EligibilityHouseholdController < QuestionsController
    include AnonymousIntakeConcern

    layout "intake"

    def next_path
      TriageResultService.new(current_intake).after_household_triaged_route || super
    end

    def illustration_path; end

    private

    def allow_other_host_redirect?
      true
    end
  end
end