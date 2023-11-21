module StateFile
  module Questions
    class SubmissionConfirmationController < QuestionsController
      def edit
        super

        StateFileEfileDeviceInfo.find_or_create_by!(
          event_type: "submission",
          ip_address: request.remote_ip,
          device_id: nil,
          intake: current_intake,
        )
      end

      private

      def form_class
        NullForm
      end
    end
  end
end
