module Questions
  class TriageBacktaxesController < AnonymousIntakeController
    layout "yes_no_question"

    skip_before_action :require_intake

    def edit
      @form = form_class.new
    end

    def update
      @form = form_class.new(form_params)
      redirect_to next_path
    end

    private

    def illustration_path
      "calendar-check.svg"
    end

    def next_path
      @form.filed_previous_years? ? super : triage_arp_questions_path
    end

    def prev_path
      :back
    end

    def method_name
      "filed_previous_years"
    end
  end
end
