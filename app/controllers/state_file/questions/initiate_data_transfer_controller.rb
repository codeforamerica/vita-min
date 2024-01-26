module StateFile
  module Questions
    class InitiateDataTransferController < QuestionsController
      include IrsDataTransferLinksConcern

      def edit
        @fake_data_transfer_link = fake_data_transfer_link
        @irs_df_transfer_link = irs_df_transfer_link
      end

      private

      def form_class
        NullForm
      end
    end
  end
end