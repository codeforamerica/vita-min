module Questions
  class TriageAssistanceController < TriageController
    layout "intake"

    private

    def next_path
      TriageResultService.new(current_triage).after_assistance || super
    end

    def illustration_path; end
  end
end
