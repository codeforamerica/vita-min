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
        @go_back_link = case current_state_code
                        when "ny"
                          ny_questions_initiate_data_transfer_path
                        when "az"
                          az_questions_initiate_data_transfer_path
                        end
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