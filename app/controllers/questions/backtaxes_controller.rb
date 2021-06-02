module Questions
  class BacktaxesController < AnonymousIntakeController
    skip_before_action :require_intake
    before_action :check_for_triage, only: [:edit]
    layout "intake"

    def current_intake
      Intake.new
    end

    private

    ##
    # looks for a triage source
    def check_for_triage
      if stimulus_triage_id = session.delete(:stimulus_triage_id)
        session[:triage_source_id] = stimulus_triage_id
        session[:triage_source_type] = StimulusTriage.to_s
      end
    end

    ##
    # sets new intake id in session and associates triage source to that intake
    def after_update_success
      new_intake = @form.intake
      session[:intake_id] = new_intake.id
      assign_triage_source(new_intake)
      new_intake.set_navigator(session[:navigator])
    end

    ##
    # looks for a triage source and attaches to intake
    def assign_triage_source(intake)
      return unless session.key?(:triage_source_id) && session.key?(:triage_source_type)

      triage_type = session.delete(:triage_source_type).constantize
      triage_source = triage_type.find(session.delete(:triage_source_id))
      intake.update_attribute(:triage_source, triage_source)
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
  end
end
