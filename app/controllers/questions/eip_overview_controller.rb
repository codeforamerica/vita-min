module Questions
  class EipOverviewController < QuestionsController
    def current_intake
      Intake::GyrIntake.new(eip_only: true)
    end

    def illustration_path
      "hand-holding-check.svg"
    end

    def form_params
      super.merge(
        source: source,
        referrer: referrer,
        locale: I18n.locale,
        visitor_id: visitor_id
      )
    end

    def after_update_success
      session[:intake_id] = @form.intake.id
      stimulus_triage_id = session.delete(:stimulus_triage_id)
      if stimulus_triage_id.present?
        @form.intake.update(triage_source: StimulusTriage.find(stimulus_triage_id))
      end
    end
  end
end
