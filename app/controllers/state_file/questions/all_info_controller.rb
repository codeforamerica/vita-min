module StateFile
  module Questions
    class AllInfoController < QuestionsController
      layout "state_file/question"

      private

      def illustration_path
        "wages.svg"
      end

      def after_update_success
        session[:intake_id] = current_intake.id
      end

      def current_intake
        @intake ||= StateFileNyIntake.new(
          tax_return_year: 2022,
          city: "New York",
          primary_first_name: "Statesy",
          primary_last_name: "Filerton",
          ssn: "222334444",
          street_address: "45 Rockefeller Plaza",
          zip_code: "10111",
          tp_id: "NY1232340",
          birth_date: Date.new(1970, 5, 18)
        )
      end
    end
  end
end
