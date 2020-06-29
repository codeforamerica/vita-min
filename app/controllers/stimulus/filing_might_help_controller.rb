module Stimulus
  class FilingMightHelpController < StimulusController
    layout 'question'

    def edit
      render plain: "next page goes here"
    end


    class << self
      def form_class
        Stimulus::NullForm
      end
    end
  end
end
