module Stimulus
  class FileForStimulusController < StimulusController
    layout 'intake'

    class << self
      def show?(triage)
        triage.need_to_correct_yes? || triage.need_to_file_yes? || triage.need_to_correct_unsure? || triage.need_to_file_unsure?
      end

      def form_class
        Stimulus::NullForm
      end
    end
  end
end
