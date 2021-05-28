module Questions
  class TriageArpController < TriageController
    layout "intake"

    private

    def illustration_path
      "calendar-clock.svg"
    end

    def form_class
      NullForm
    end
  end
end
