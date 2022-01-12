module Questions
  class TriageExpressController < TriageController
    layout "intake"

    def self.show(triage)
      false
    end

    private

    def illustration_path; end

    def form_class; NullForm; end
  end
end
