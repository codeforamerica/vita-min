module Ctc
  module Questions
    module W2s
      class EmployerInfoController < BaseW2Controller
        before_action :set_continue_label

        private

        def illustration_path
          "documents.svg"
        end

        def set_continue_label
          @continue_label = t("views.ctc.questions.w2s.employer_info.add")
        end
      end
    end
  end
end
