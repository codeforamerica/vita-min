module Questions
  class TriageBacktaxesController < TriageController
    layout "yes_no_question"

    private

    def illustration_path
      "calendar-check.svg"
    end

    def next_path
      @form.filed_previous_years? ? super : triage_arp_questions_path
    end

    def method_name
      "filed_previous_years"
    end
  end
end
