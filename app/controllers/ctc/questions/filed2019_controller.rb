module Ctc
  module Questions
    class Filed2019Controller < QuestionsController

      layout "intake"

      private

      def method_name
        "filed_2019"
      end

      def next_path
        @form.filed_2019? ? questions_use_gyr_path : super
      end

      def illustration_path
        "hand-holding-check.svg"
      end
    end
  end
end