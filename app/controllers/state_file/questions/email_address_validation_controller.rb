module StateFile
  module Questions
    class EmailAddressValidationController < QuestionsController
      def edit
        super
        State_file_archived_intake_access_logs.create(
          event_type: "submission",
          ip_address: ip_for_irs,
          intake: current_intake,
          )
      end

    end
  end
end