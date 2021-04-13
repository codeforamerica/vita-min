module Questions
  class TriageStimulusCheckController < AnonymousIntakeController
    layout "intake"
    skip_before_action :require_intake

    def update
      redirect_to next_path
    end

    private

    def illustration_path
      "hand-holding-check.svg"
    end

    def form_class
      NullForm
    end

    def prev_path
      :back
    end
  end
end
