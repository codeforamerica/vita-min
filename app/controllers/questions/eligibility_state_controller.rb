module Questions
  class EligibilityStateController < QuestionsController
    include AnonymousIntakeConcern

    layout "intake"

    def next_path
      if Flipper.enabled?(:show_simple_file)
        super
      else
        TriageResultService.new(current_intake).after_income_levels_triaged_route || super
      end
    end

    def illustration_path; end
  end
end
