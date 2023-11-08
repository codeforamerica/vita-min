module StateFile
  module Questions
    class InitiateDataTransferController < QuestionsController
      def edit
        return_url = URI(form_navigation.next.to_path_helper(full_url: true, us_state: params[:us_state]))
        return_url.host = request.host

        @link = URI(state_file_fake_direct_file_transfer_page_path)
        @link.query = { redirect: return_url }.to_param
      end

      private

      def form_class
        NullForm
      end
    end
  end
end