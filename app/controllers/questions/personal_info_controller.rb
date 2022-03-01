module Questions
  class PersonalInfoController < QuestionsController
    include AnonymousIntakeConcern
    skip_before_action :require_intake

    def current_intake
      Intake::GyrIntake.new
    end

    def tracking_data
      {}
    end

    private

    def illustration_path; end

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
  end
end
