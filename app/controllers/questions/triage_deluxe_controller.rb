module Questions
  class TriageDeluxeController < TriageController
    layout "intake"

    def self.show?(triage)
      false
    end

    private

    def illustration_path
      "document-success.svg"
    end

    def form_class; NullForm; end
  end
end
