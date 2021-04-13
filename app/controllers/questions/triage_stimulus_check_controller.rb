module Questions
  class TriageStimulusCheckController < TriageController
    layout "intake"

    private

    def illustration_path
      "hand-holding-check.svg"
    end

    def form_class
      NullForm
    end
  end
end
