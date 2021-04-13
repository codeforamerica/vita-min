module Questions
  class TriageArpController < AnonymousIntakeController
    layout "intake"

    skip_before_action :require_intake

    def update
      redirect_to next_path
    end

    private

    def prev_path
      :back
    end

    def illustration_path
      "calendar-clock.svg"
    end

    def form_class
      NullForm
    end

    # Use redirect instead of self.show? to exclude
    # because accessing session isn't compatible with ControllerNavigation#seek implementation
    def redirect_unless_eip_only
      redirect_to next_path unless session[:eip_only]
    end
  end
end
