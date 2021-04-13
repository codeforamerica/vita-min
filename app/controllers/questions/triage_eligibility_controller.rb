module Questions
  class TriageEligibilityController < AnonymousIntakeController
    skip_before_action :require_intake

    layout "intake"

    def edit
      @form = form_class.new
    end

    def update
      @form = form_class.new(form_params)
      redirect_to next_path
    end

    private

    def next_path
      @form.eligible? ? super : maybe_ineligible_path
    end

    def prev_path
      :back
    end

    def illustration_path; end
  end
end
