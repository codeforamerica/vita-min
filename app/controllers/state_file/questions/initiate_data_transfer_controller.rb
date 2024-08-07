module StateFile
  module Questions
    class InitiateDataTransferController < QuestionsController
      include IrsDataTransferLinksConcern

      def edit
        if current_intake.state_file_analytics&.initiate_data_transfer_first_visit_at&.nil?
          current_intake.state_file_analytics.update!(initiate_data_transfer_first_visit_at: DateTime.now)
        end
        @fake_data_transfer_link = fake_data_transfer_link
        @irs_df_transfer_link_present = irs_df_transfer_link.present?
      end

      def initiate_data_transfer
        current_intake.state_file_analytics.update(
          initiate_df_data_transfer_clicks: current_intake.state_file_analytics.initiate_df_data_transfer_clicks + 1
        )
        redirect_to irs_df_transfer_link.to_s, allow_other_host: true
      end

      private

      def form_class
        NullForm
      end
    end
  end
end
