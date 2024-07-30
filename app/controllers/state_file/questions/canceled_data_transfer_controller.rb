module StateFile
  module Questions
    class CanceledDataTransferController < QuestionsController
      include IrsDataTransferLinksConcern
      skip_before_action :set_current_step

      def self.show?(_intake)
        false
      end

      def edit
        current_intake.state_file_analytics.update!(
          canceled_data_transfer_count: current_intake.state_file_analytics.canceled_data_transfer_count + 1
        )
        @fake_data_transfer_link = fake_data_transfer_link
        @irs_df_transfer_link = irs_df_transfer_link
        @go_back_link = questions_initiate_data_transfer_path
      end

      def illustration_path
        "error-circle.svg"
      end

      private

      def prev_path
        nil
      end
    end
  end
end