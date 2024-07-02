FactoryBot.define do
  factory "414h_test", class: StateFileNyIntake do
    raw_direct_file_data { StateFile::XmlReturnSampleService.new.read("ny_414h_test") }
    primary_first_name { "Javier" }
    primary_middle_initial { "D" }
    primary_last_name { "Jimenez" }
    primary_birth_date { "1968-01-25" }

    nyc_maintained_home { "no" }
    nyc_residency { "none" }
    occupied_residence { "unfilled" }

    residence_county { "Westchester" }

    school_district { "Pleasantville" }
    school_district_id { 988 }
    school_district_number { 504 }

    permanent_city { "Pleasantville" }
    permanent_street { "123 Main St" }
    permanent_zip { "10572" }

    after(:create) do |intake|
      create(
        :state_file1099_g,
        intake: intake,
        payer_name: "New York State Dept of Labor",
        payer_tin: "270293117",
        payer_street_address: "Payment Unit Building 12 1099-G PO Box 621",
        payer_city: "Albany",
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
    withdraw_amount { 67 }

    primary_esigned { "yes" }
    primary_esigned_at { "2024-06-25 21:17:06.557058000 +0000" }

    federal_submission_id { "12345202201011234570" }
  end
end