module Questions
  class TriageIdTypeController < TriageController
    layout "intake"

    def self.show?(triage)
      false
    end

    private

    def next_path
      TriageResultService.new(current_triage).after_id_type || super
    end

    def illustration_path
      "id-guidance.svg"
    end
  end
end
