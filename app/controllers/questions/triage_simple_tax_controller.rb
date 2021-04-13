module Questions
  class TriageSimpleTaxController < AnonymousIntakeController
    layout "yes_no_question"

    skip_before_action :require_intake

    def illustration_path
      "documents.svg"
    end

    def edit
      @form = form_class.new
    end

    def update
      @form = form_class.new(form_params)
      redirect_to next_path
    end

    def next_path
      @form.has_simple_taxes? ? super : triage_arp_questions_path
    end

    def method_name
      "has_simple_taxes"
    end
  end
end
