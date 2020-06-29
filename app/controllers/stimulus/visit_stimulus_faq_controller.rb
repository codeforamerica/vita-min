module Stimulus
  class VisitStimulusFaqController < StimulusController

    def edit
      render plain: 'page not yet built'
    end

    class << self
      def form_class
        Stimulus::NullForm
      end
    end
  end
end
