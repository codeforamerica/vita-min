module Questions
  class BacktaxesController < QuestionsController
    skip_before_action :require_intake
    before_action :check_for_triage, only: [:edit]
    layout "question"

    def current_intake
      super || Intake.new
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

    def after_update_success
      session[:intake_id] = @form.intake.id
      assign_triage_source
    end

    ##
    # after creating an intake, looks for a triage source and attaches
    # to intake
    def assign_triage_source
      return unless session.key?(:triage_source_id) && session.key?(:triage_source_type)

      triage_type = session.delete(:triage_source_type).constantize
      triage_source = triage_type.find(session.delete(:triage_source_id))
      current_intake.update_attribute(:triage_source, triage_source)
    end

    def form_params
      super.merge(
        source: current_intake.source || source,
        referrer: current_intake.referrer || referrer,
        locale: I18n.locale,
        )
    end
  end
end
