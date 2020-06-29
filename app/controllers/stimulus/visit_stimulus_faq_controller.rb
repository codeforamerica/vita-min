module Stimulus
  class VisitStimulusFaqController < StimulusController
    layout 'question'
    after_action :clear_stimulus_triage_session


    class << self
      def form_class
        Stimulus::NullForm
      end

      def show?(triage)
        triage.filed_prior_years_yes?
      end
    end

    def clear_stimulus_triage_session
      session.delete(:stimulus_triage_id)
    end
  end
end
