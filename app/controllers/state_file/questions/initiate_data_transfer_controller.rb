module StateFile
  module Questions
    class InitiateDataTransferController < QuestionsController
      private

      def form_class
        NullForm
      end
    end
  end
end