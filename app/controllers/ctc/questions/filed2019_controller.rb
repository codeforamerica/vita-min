module Ctc
  module Questions
    class Filed2019Controller < QuestionsController

      layout "yes_no_question"

      private

      def method_name
        "filed_2019"
      end

      def next_path
        @form.filed_2019? ? questions_life_situations2019_path : super
      end

      def illustration_path
        "hand-holding-check.svg"
      end
    end
  end
end