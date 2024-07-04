FactoryBot.define do
  factory "javier", class: StateFileNyIntake do
    raw_direct_file_data { StateFile::XmlReturnSampleService.new.read("ny_javier") }
    primary_first_name { "JAVIER" }
    primary_middle_initial { "D" }
    primary_last_name { "JIMENEZ" }
    primary_birth_date { "1968-01-25" }

    nyc_maintained_home { "no" }
    nyc_residency { "none" }
    occupied_residence { "unfilled" }

    residence_county { "Greene" }

    school_district { "Greenville" }
    school_district_id { 299 }
    school_district_number { 240 }

    permanent_city { "GREENVILLE" }
    permanent_street { "121 MAPLE AVE" }
    permanent_zip { "12083" }

    after(:create) do |intake|
      create(
        :state_file1099_g,
        intake: intake,
        payer_name: "NEW YORK STATE DEPT OF LABOR",
        payer_tin: "270293117",
        payer_street_address: "PAYMENT UNIT BLDG 12",
        payer_city: "ALBANY",
        payer_zip: "12201",
        recipient: "primary",
        recipient_street_address: "123 Main St",
        recipient_city: "Pleasantville",
        recipient_zip: "10572",
        unemployment_compensation: 500,
        federal_income_tax_withheld: 0,
        state_identification_number: "270293117",
        state_income_tax_withheld: 50,
      )
    end

    payment_or_deposit_type { "direct_deposit" }
    bank_name { "FYST Bank" }
    account_type { "checking" }
    routing_number { "011001742" }
    account_number { "99990000001011" }

    date_electronic_withdrawal { "2024-04-15" }
    withdraw_amount { 163 }

    primary_esigned { "yes" }
    primary_esigned_at { "2024-07-3" }

    federal_submission_id { "1016422024018atw000x" }
  end
end