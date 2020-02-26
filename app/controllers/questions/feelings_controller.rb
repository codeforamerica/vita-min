module Questions
  class FeelingsController < QuestionsController
    skip_before_action :require_sign_in
    layout "question"

    def current_intake
      super || Intake.new
    end

    private

    def after_update_success
      session[:intake_id] = @form.intake.id
    end

    def illustration_path; end

    def form_params
      super.merge(
        source: current_intake.source || source,
        referrer: current_intake.referrer || referrer,
      )
    end
  end
end