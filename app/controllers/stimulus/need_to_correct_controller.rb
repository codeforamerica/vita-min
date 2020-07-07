module Stimulus
  class NeedToCorrectController < StimulusController
    def self.show?(stimulus_triage)
      stimulus_triage.filed_recently_yes?
    end
  end
end
