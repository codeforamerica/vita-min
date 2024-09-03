module StateFile
  module Questions
    class NcVeteranStatusController < QuestionsController
      include ReturnToReviewConcern

      def update
        update_for_device_id_collection(current_intake&.initial_efile_device_info)
      end
    end
  end
end
