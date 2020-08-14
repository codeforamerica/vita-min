module Questions
  class EipOverviewController < QuestionsController
    def current_intake
      Intake.new(eip_only: true)
    end

    def illustration_path
      "eip-check.svg"
    end

    def form_params
      super.merge(
        source: source,
        referrer: referrer,
        locale: I18n.locale,
      )
    end

    def after_update_success
      session[:intake_id] = @form.intake.id
      stimulus_triage_id = session.delete(:stimulus_triage_id)
      if stimulus_triage_id.present?
        current_intake.update(triage_source: StimulusTriage.find(stimulus_triage_id))
      end
    end
  end
end
