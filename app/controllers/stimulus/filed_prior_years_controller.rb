module Stimulus
  class FiledPriorYearsController < StimulusController
    def self.show?(stimulus_triage)
      stimulus_triage.filed_recently_yes? && stimulus_triage.need_to_correct_no?
    end

    def illustration_path
      'filed-recently.svg'
    end
  end
end
