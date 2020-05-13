module Questions
  class BacktaxesController < QuestionsController
    layout "question"

    def current_intake
      super || Intake.new
    end

    private

    def after_update_success
      session[:intake_id] = @form.intake.id
    end

    def form_params
      super.merge(
        source: current_intake.source || source,
        referrer: current_intake.referrer || referrer,
        )
    end
  end
end
