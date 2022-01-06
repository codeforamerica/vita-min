module Questions
  class TriageAssistanceController < TriageController
    layout "intake"

    class MinimumForm < Form; end

    def edit
      @form = MinimumForm.new
    end

    private

    def illustration_path; end
  end
end
