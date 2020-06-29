module Stimulus
  class FiledPriorYearsController < StimulusController
    def show?
      current_stimulus_triage.need_to_correct_no?
    end

    def illustration_path
      'filed-recently.svg'
    end
  end
end
