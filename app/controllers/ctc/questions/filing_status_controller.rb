module Ctc
  module Questions
    class FilingStatusController < QuestionsController
      include AnonymousIntakeConcern

      def edit
        super
      end

      private

      def illustration_path; end

    end
  end
end