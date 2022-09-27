module Ctc
  module Questions
    module W2s
      class MiscInfoController < BaseW2Controller
        before_action :set_continue_label

        private

        def next_path
          box12a_codes = [@w2.box12a_code, @w2.box12b_code, @w2.box12c_code, @w2.box12d_code].map(&:presence).compact
          if @w2.box13_statutory_employee_yes? || box12a_codes.any? { |code| W2::BOX12_OFFBOARD_CODES.include?(code) }
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
