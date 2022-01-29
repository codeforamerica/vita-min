module Questions
  class TriageIdTypeController < TriageController
    layout "intake"

    private

    def next_path
      TriageResultService.new(current_triage).after_id_type || super
    end

    def illustration_path
      "id-guidance.svg"
    end
  end
end
