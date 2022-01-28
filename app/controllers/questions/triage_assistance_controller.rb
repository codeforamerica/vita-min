module Questions
  class TriageAssistanceController < TriageController
    layout "intake"

    def self.show?(triage)
      false
    end

    private

    def next_path
      TriageResultService.new(current_triage).after_assistance || super
    end

    def illustration_path; end
  end
end
