module Ctc
  module Questions
    module W2s
      class WagesInfoController < BaseW2Controller
        def next_path
          if @w2.box8_allocated_tips&.positive? || @w2.box10_dependent_care_benefits&.positive?
            Ctc::Questions::UseGyrController.to_path_helper
          else
            super
          end
        end
      end
    end
  end
end
