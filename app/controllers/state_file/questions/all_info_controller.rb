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

      def next_path
        # TODO: remove when we're keeping better track of current state than this query parameter
        form_navigation.next.to_path_helper(state: params[:state])
      end

      def current_intake
        if params[:state] == "NY"
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
        elsif params[:state] == "AZ"
          @intake ||= StateFileAzIntake.new(
            tax_return_year: 2022,
            city: "Phoenix",
            primary_first_name: "Statesy",
            primary_last_name: "Filerton",
            ssn: "222334444",
            street_address: "123 Palm Tree",
            zip_code: "85001",
            birth_date: Date.new(1970, 5, 18)
          )
        else
          raise "No state specified"
        end
      end
    end
  end
end
