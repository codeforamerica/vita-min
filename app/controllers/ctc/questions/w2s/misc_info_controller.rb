module Ctc
  module Questions
    module W2s
      class MiscInfoController < BaseW2Controller
        before_action :set_continue_label

        private

        def next_path
          if current_intake.benefits_eligibility.disqualified_for_simplified_filing_due_to_w2_answers?
            Ctc::Questions::UseGyrController.to_path_helper
          else
            super
          end
        end

        def set_continue_label
          @continue_label = t("views.ctc.questions.w2s.misc_info.submit")
        end
      end
    end
  end
end
