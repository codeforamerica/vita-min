module Stimulus
  class FiledRecentlyController < StimulusController
    def current_stimulus_triage
      super || StimulusTriage.new
    end

    def update
      session[:stimulus_triage_id] = nil
      super
    end

    def after_update_success
      session[:stimulus_triage_id] = @form.stimulus_triage.id
    end

    private

    def form_params
      super.merge(
        source: current_stimulus_triage.source || source,
        referrer: current_stimulus_triage.referrer || referrer,
      )
    end
  end
end
