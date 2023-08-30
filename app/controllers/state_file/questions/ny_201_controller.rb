module StateFile
  module Questions
    class Ny201Controller < QuestionsController
      layout "state_file/question"

      private

      def illustration_path
        "wages.svg"
      end

      def after_update_success
        session[:intake_id] = current_intake.id
      end

      def current_intake
        case params[:us_state]
        when "ny"
          @intake ||= StateFileNyIntake.new(
            tax_return_year: 2022,
            filing_status: :single,
            primary_first_name: "Statesy",
            primary_middle_initial: "M",
            primary_last_name: "Filerton",
            primary_dob: Date.new(1970, 5, 18),
            primary_ssn: "555002222",
            primary_occupation: "plumber",
            mailing_city: "New York",
            mailing_street: "45 Rockefeller Plaza",
            mailing_apartment: "B",
            mailing_zip: "10111",
            claimed_as_dep: "no",
            phone_daytime: "5551212",
            phone_daytime_area_code: "888",
            spouse_first_name: "NewYork",
            spouse_middle_initial: "E",
            spouse_last_name: "Filerton",
            spouse_dob: Date.new(1971, 6, 3),
            spouse_ssn: "555001111",
            spouse_occupation: "plumber",
            fed_wages: 123,
            fed_taxable_income: 12,
            fed_unemployment: 34,
            fed_taxable_ssb: 4,
            total_fed_adjustments_identify: "wrenches",
            total_fed_adjustments: 45,
            total_ny_tax_withheld: 56
          )
        when "az"
          @intake ||= StateFileAzIntake.new(
            tax_return_year: 2022,
            primary_first_name: "Statesy",
            primary_middle_initial: "M",
            primary_last_name: "Filerton",
            primary_ssn: "555002222",
            primary_dob: Date.new(1970, 5, 18),
            primary_occupation: "plumber",
            mailing_city: "Phoenix",
            mailing_street: "123 Palm Tree",
            mailing_apartment: "C",
            mailing_zip: "85001",
            claimed_as_dep: "no",
            phone_daytime: "5551212",
            phone_daytime_area_code: "888",
            spouse_first_name: "Fenix",
            spouse_middle_initial: "E",
            spouse_last_name: "Filerton",
            spouse_dob: Date.new(1971, 6, 3),
            spouse_ssn: "555001111",
            spouse_occupation: "plumber",
            fed_wages: 123,
            fed_taxable_income: 12,
            fed_unemployment: 34,
            fed_taxable_ssb: 4,
            total_fed_adjustments_identify: "wrenches",
            total_fed_adjustments: 45,
            total_ny_tax_withheld: 56
          )
        else
          raise "No state specified"
        end
      end
    end
  end
end
