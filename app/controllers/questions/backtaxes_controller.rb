module Questions
  class BacktaxesController < QuestionsController
    include AnonymousIntakeConcern
    skip_before_action :require_intake
    before_action :load_possible_filing_years, only: [:edit, :update]
    layout "intake"

    def current_intake
      Intake::GyrIntake.new
    end

    private

    ##
    # sets new intake id in session and associates triage source to that intake
    def after_update_success
      new_intake = @form.intake
      session[:intake_id] = new_intake.id
      new_intake.set_navigator(session[:navigator])
      current_triage&.update(intake_id: new_intake.id)
    end

    def form_params
      super.merge(
        source: current_intake.source || source,
        referrer: current_intake.referrer || referrer,
        locale: I18n.locale,
        visitor_id: visitor_id
      )
    end

    def illustration_path
      "calendar.svg"
    end

    def load_possible_filing_years
      @possible_filing_years = TaxReturn.filing_years
    end
  end
end
