module StateFile
  module Questions
    class FederalInfoController < QuestionsController
      layout "state_file/question"

      def update_with_sample_data
        update_intake_with_sample_data
        redirect_to action: :edit, us_state: params[:us_state]
      end

      private

      def illustration_path
        "wages.svg"
      end

      def update_intake_with_sample_data
        case params[:us_state]
        when "ny"
          current_intake.update(
            claimed_as_dep: "no",
            primary_email: "whatever@example.com",
            date_electronic_withdrawal: Date.today,
            residence_county: "COUN",
            school_district: "Pizza District",
            school_district_number: 234,
            nyc_full_year_resident: "yes",
            ny_414h_retirement: 567,
            ny_other_additions: 123,
            amount_owed_pay_electronically: "yes",
            refund_choice: "paper",
            account_type: "personal_checking",
            routing_number: "013456789",
            account_number: "456789008765",
            amount_electronic_withdrawal: 768,
            primary_signature: "beep boop",
            spouse_signature: "hup",
            **it214_fields
          )
        when "az"
          intake = current_intake.update(claimed_as_dep: "no")
        else
          raise "No state specified"
        end
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
