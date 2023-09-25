module StateFile
  module Questions
    class FederalInfoController < QuestionsController
      layout "state_file/question"

      def import_federal_data
        if current_intake.persisted?
          flash[:alert] = "not overriding existing session intake for now"
          redirect_to action: :edit, us_state: params[:us_state]
        else
          create_sample_intake
          redirect_to action: :edit, us_state: params[:us_state]
        end
      end

      private

      def current_intake
        super_value = super
        if super_value.present?
          super_value
        else
          question_navigator.intake_class.new
        end
      end

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
            total_state_tax_withheld: 56,
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
            spouse_signature: "hup",
            **it214_fields
          )
          intake.dependents.create(
            first_name: "Adult",
            middle_initial: 'C',
            last_name: "Deppy",
            relationship: Efile::Relationship.find('grandparent').irs_enum,
            ssn: '555003333',
            dob: 60.years.ago
          )
          intake.dependents.create(
            first_name: "Child",
            middle_initial: 'E',
            last_name: "Deppy",
            relationship: Efile::Relationship.find('daughter').irs_enum,
            ssn: '555004444',
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
            total_state_tax_withheld: 56
          )
        else
          raise "No state specified"
        end
        session[:state_file_intake] = intake.to_global_id
      end

      def it214_fields
        {
          ny_mailing_street: "123 Homeowner way",
          ny_mailing_apartment: "B",
          ny_mailing_city: "Brooklyn",
          ny_mailing_zip: "10113",
          occupied_residence: "yes",
          property_over_limit: "no",
          public_housing: "no",
          nursing_home: "no",
          household_fed_agi: 1234,
          household_ny_additions: 1234,
          household_ssi: 1234,
          household_cash_assistance: 1234,
          household_other_income: 1234,
          household_rent_own: "own",
          household_rent_amount: 0,
          household_rent_adjustments: 123,
          household_own_propety_tax: 123,
          household_own_assessments: 123,
        }
      end
    end
  end
end
