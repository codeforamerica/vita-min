module Questions
  class TriageBacktaxesController < TriageController
    layout "yes_no_question"

    private

    def illustration_path
      "calendar-check.svg"
    end

    def method_name
      "filed_previous_years"
    end
  end
end
