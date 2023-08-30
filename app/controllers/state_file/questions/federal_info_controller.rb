module StateFile
  module Questions
    class FederalInfoController < QuestionsController
      layout "state_file/question"

      def edit
        create_sample_intake unless current_intake
        super
      end

      private

      def illustration_path
        "wages.svg"
      end

      def after_update_success
        session[:state_file_intake] = current_intake.to_global_id
      end

      def create_sample_intake
        case params[:us_state]
        when "ny"
          intake = StateFileNyIntake.create(
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
            total_ny_tax_withheld: 56,
            primary_email: "statesy@example.com",
            date_electronic_withdrawal: Date.today,
            residence_county: "County",
            school_district: "Pizza District",
            school_district_number: 234,
            permanent_street: "123 Main St",
            permanent_apartment: "3",
            permanent_city: "New York",
            permanent_zip: "10112",
            nyc_resident_e: "yes",
            ny_414h_retirement: 567,
            ny_other_additions: 123,
            sales_use_tax: 345,
            amount_owed_pay_electronically: "yes",
            refund_choice: "paper",
            account_type: "personal_checking",
            routing_number: "34567878",
            account_number: "456789008765",
            amount_electronic_withdrawal: 768,
            primary_signature: "beep boop",
            spouse_signature: "hup"
          )
          intake.dependents.create(
            first_name: "Adult",
            last_name: "Deppy",
            dob: 60.years.ago
          )
          intake.dependents.create(
            first_name: "Child",
            last_name: "Deppy",
            dob: 6.years.ago
          )
        when "az"
          intake = StateFileAzIntake.create(
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
        session[:state_file_intake] = intake.to_global_id
      end
    end
  end
end
