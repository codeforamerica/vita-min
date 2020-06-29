module Stimulus
  class NeedToFileController < StimulusController
    def illustration_path
      "filed-recently.svg"
    end

    def self.show?(stimulus_triage)
      stimulus_triage.filed_recently_no?
    end
  end
end
