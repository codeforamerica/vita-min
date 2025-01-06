module StateFile
  module Questions
    class EmailAddressValidationController < QuestionsController
      def edit
        # binding.pry
        super
        ::StateFileArchivedIntakeAccessLog.create(
          event_type: "submission",
          ip_address: ip_for_irs,
          )
      end

    end
  end
end