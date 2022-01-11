module Questions
  class TriageDocTypeController < TriageController
    layout "intake"

    private

    def illustration_path
      "documents.svg"
    end
  end
end
