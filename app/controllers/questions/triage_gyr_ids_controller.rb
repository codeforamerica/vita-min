module Questions
  class TriageGyrIdsController < TriageController
    layout "intake"

    def self.show?(triage)
      true
    end

    private

    def illustration_path
      "id-guidance.svg"
    end

    def form_class; NullForm; end
  end
end
