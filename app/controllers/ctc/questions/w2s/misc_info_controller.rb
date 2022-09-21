module Ctc
  module Questions
    module W2s
      class MiscInfoController < BaseW2Controller
        before_action :set_continue_label

        private

        def set_continue_label
          @continue_label = t("views.ctc.questions.w2s.misc_info.submit")
        end
      end
    end
  end
end
