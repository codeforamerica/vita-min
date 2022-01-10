module Questions
  class TriageDocTypeController < TriageController
    layout "intake"

    class MinimumForm < Form
    end

    def edit
      @form = MinimumForm.new
    end

    private

    def illustration_path
      "documents.svg"
    end
  end
end
