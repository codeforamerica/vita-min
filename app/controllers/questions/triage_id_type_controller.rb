module Questions
  class TriageIdTypeController < TriageController
    layout "intake"

    private

    def illustration_path
      "id-guidance.svg"
    end
  end
end
