module Questions
  class TriageDocTypeController < TriageController
    layout "intake"

    private

    def next_path
      TriageResultService.new(current_triage).after_doc_type || super
    end

    def illustration_path
      "documents.svg"
    end
  end
end
