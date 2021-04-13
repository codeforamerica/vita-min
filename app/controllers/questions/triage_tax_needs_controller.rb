module Questions
  class TriageTaxNeedsController < TriageController
    layout "intake"

    private

    def next_path
      @form.stimulus_only? ? super : triage_eligibility_questions_path
    end

    def illustration_path; end
  end
end