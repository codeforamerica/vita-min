module Ctc
  module Questions
    module W2s
      class MiscInfoController < BaseW2Controller
        before_action :set_continue_label

        private

        def next_path
          if @w2.box13_statutory_employee_yes?
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
