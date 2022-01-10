module Questions
  class TriageStartIdsController < TriageController
    layout "intake"
    before_action :require_triage

    def edit
    end

    private

    def illustration_path
      "documents-and-ids.svg"
    end
  end
end
