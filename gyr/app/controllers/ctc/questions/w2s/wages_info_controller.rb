module Ctc
  module Questions
    module W2s
      class WagesInfoController < BaseW2Controller
        def next_path
          if current_intake.benefits_eligibility.disqualified_for_simplified_filing_due_to_w2_answers?
            Ctc::Questions::UseGyrController.to_path_helper
          else
            super
          end
        end
      end
    end
  end
end
