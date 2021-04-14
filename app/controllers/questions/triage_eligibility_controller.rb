module Questions
  class TriageEligibilityController < TriageController
    layout "intake"

    private

    def next_path
      @form.eligible? ? super : maybe_ineligible_path
    end

    def illustration_path; end
  end
end
