module Questions
  class TriageLookbackController < TriageController
    layout "intake"

    private

    def illustration_path
      "hand-holding-cash.svg"
    end
  end
end
