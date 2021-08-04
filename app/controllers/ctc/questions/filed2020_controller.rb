module Ctc
  module Questions
    class Filed2020Controller < QuestionsController

      layout "yes_no_question"

      private

      def method_name
        "filed_2020"
      end

      def next_path
        @form.filed_2020? ? questions_filed2020_yes_path : super
      end

      def illustration_path
        "hand-holding-check.svg"
      end
    end
  end
end