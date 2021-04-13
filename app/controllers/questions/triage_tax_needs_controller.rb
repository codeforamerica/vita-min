module Questions
  class TriageTaxNeedsController < AnonymousIntakeController
    skip_before_action :require_intake

    layout "intake"

    def edit
      @form = form_class.new
    end

    def update
      @form = form_class.new(form_params)
      render :edit and return unless @form.valid?

      # session[:eip_only] = @form.stimulus_only? # indicate to make as stimulus only when intake is created.
      redirect_to next_path
    end

    private

    def next_path
      @form.stimulus_only? ? super : triage_eligibility_questions_path
    end

    def prev_path
      :back
    end

    def illustration_path; end
  end
end