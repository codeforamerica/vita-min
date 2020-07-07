module Stimulus
  class FileForStimulusController < StimulusController
    layout 'question'

    class << self
      def show?(triage)
        triage.need_to_correct_yes? || triage.need_to_file_yes?
      end

      def form_class
        Stimulus::NullForm
      end
    end
  end
end
