module Stimulus
  class VisitStimulusFaqController < StimulusController

    def edit
      render plain: 'fix me'
    end

    class << self
      def form_class; NullForm; end
    end
  end
end
