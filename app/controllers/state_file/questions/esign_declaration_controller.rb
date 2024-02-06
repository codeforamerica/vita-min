module StateFile
  module Questions
    class EsignDeclarationController < AuthenticatedQuestionsController
      def edit
        super
        StateFileEfileDeviceInfo.find_or_create_by!(
          event_type: "submission",
          ip_address: ip_for_irs,
          intake: current_intake,
          )
      end

      def update
        update_for_device_id_collection(current_intake&.submission_efile_device_info)
      end

      private

      def card_postscript; end

    end
  end
end
