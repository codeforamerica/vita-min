module Questions
  class AlreadyFiledController < QuestionsController
    skip_before_action :require_intake
    layout "yes_no_question"

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
        locale: I18n.locale,
        )
    end

    def illustration_path
      "backtaxes.svg"
    end

    def show_progress?
      false
    end
  end
end
