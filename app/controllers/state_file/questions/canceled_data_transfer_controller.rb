module StateFile
  module Questions
    class CanceledDataTransferController < QuestionsController
      include IrsDataTransferLinksConcern
      before_action :redirect_if_no_us_state_in_params
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
        @go_back_link = StateFile::Questions::InitiateDataTransferController.to_path_helper(action: :initiate_data_transfer, us_state: current_intake.state_code)
      end

      def illustration_path
        "error-circle.svg"
      end

      private

      # in order to give the IRS team one cancel link, this controller will redirect to the path with the us_state
      # based on the intake in the session; part of the reason for this is so we can leverage the default implementation
      # of
      def redirect_if_no_us_state_in_params
        return if params[:us_state]

        if session[:state_file_intake].present?
          if current_intake.class == StateFileAzIntake
            redirect_link = az_questions_canceled_data_transfer_path(us_state: "az")
          elsif current_intake.class == StateFileNyIntake
            redirect_link = ny_questions_canceled_data_transfer_path(us_state: "ny")
          end
        else          # TODO: is there something else we should do if they have no intake in the session?
          redirect_link = root_path
        end
        redirect_to redirect_link
      end

      def prev_path
        nil
      end
    end
  end
end