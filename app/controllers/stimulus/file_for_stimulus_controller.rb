module Stimulus
  class FileForStimulusController < StimulusController
    layout 'question'

    def form_class; NullForm; end

    class << self
      def show?(triage)
        triage.need_to_correct_yes? || triage.need_to_file_yes?
      end
    end
  end
end
