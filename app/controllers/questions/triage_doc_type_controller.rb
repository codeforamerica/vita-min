module Questions
  class TriageDocTypeController < TriageController
    layout "intake"

    def self.show?(triage)
      false
    end

    private

    def next_path
      TriageResultService.new(current_triage).after_doc_type || super
    end

    def illustration_path
      "documents.svg"
    end
  end
end
