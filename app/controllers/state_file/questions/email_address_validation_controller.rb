module StateFile
  module Questions
    class EmailAddressValidationController < QuestionsController
      def edit
        super
        # ::StateFileArchivedIntakeAccessLog.create(
        #   event_type: "submission",
        #   ip_address: ip_for_irs,
        #   intake: current_intake,
        #   )
      end

    end
  end
end