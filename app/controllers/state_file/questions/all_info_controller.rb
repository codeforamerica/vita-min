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
        case params[:state]
        when "NY"
          @intake ||= StateFileNyIntake.new(
            tax_return_year: 2022,
            primary_first_name: "Statesy",
            primary_last_name: "Filerton",
            primary_dob: Date.new(1970, 5, 18),
            primary_ssn: "555002222",
            mailing_city: "New York",
            mailing_street: "45 Rockefeller Plaza",
            mailing_zip: "10111",
          )
        when "AZ"
          @intake ||= StateFileAzIntake.new(
            tax_return_year: 2022,
            primary_first_name: "Statesy",
            primary_last_name: "Filerton",
            primary_ssn: "555002222",
            primary_dob: Date.new(1970, 5, 18),
            mailing_city: "Phoenix",
            mailing_street: "123 Palm Tree",
            mailing_zip: "85001",
          )
        else
          raise "No state specified"
        end
      end
    end
  end
end
