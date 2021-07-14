module Ctc
  module Questions
    class ConsentController < QuestionsController
      include AnonymousIntakeConcern

      layout "intake"

      def update
        super
      end

      private

      def illustration_path
        nil
      end
    end
  end
end