module StateFile
  module Questions
    class DataReviewController < QuestionsController
      def edit
        super
        #update device id later
        StateFileEfileDeviceInfo.find_or_create_by!(
          event_type: "initial_creation",
          ip_address: request.remote_ip,
          device_id: nil,
          intake: current_intake,
        )
      end

      private

      def form_class
        StateFile::EfileDeviceInfoForm
      end

      def prev_path
        nil
      end
    end
  end
end
