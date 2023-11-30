module StateFile
  module Questions
    class InitiateDataTransferController < QuestionsController
      include IrsDataTransferLinksConcern

      def edit
        @link = data_transfer_link
        @irs_testing_link = irs_testing_link
      end

      private

      def form_class
        NullForm
      end
    end
  end
end