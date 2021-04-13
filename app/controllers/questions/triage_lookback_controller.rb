module Questions
  class TriageLookbackController < AnonymousIntakeController
    layout "intake"
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
      "hand-holding-cash.svg"
    end

    def next_path
      @form.has_complex_situation? ? triage_arp_questions_path : super
    end
  end
end
