module StateFile
  module Questions
    class DataReviewController < QuestionsController
      def edit
        super
        # todo: create only if not already created
        StateFileEfileDeviceInfo.create!(
          ip_address: request.remote_ip,
          device_id: nil,
          event_type: "initial_creation",
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
