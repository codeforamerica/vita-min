module Questions
  class TriageStartIdsController < TriageController
    layout "intake"

    private

    def illustration_path
      "documents-and-ids.svg"
    end

    def form_class; NullForm; end
  end
end
