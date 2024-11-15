FactoryBot.define do
  factory "johnny", class: StateFileAzIntake do
    raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml("az_johnny_mfj_8_deps") }
    raw_direct_file_intake_data { StateFile::DirectFileApiResponseSampleService.new.read_json("az_johnny_mfj_8_deps") }

    after(:create) do |intake|
      intake.synchronize_df_dependents_to_database
      intake.synchronize_df_1099_rs_to_database
      intake.synchronize_df_w2s_to_database
      intake.synchronize_filers_to_database

      intake.dependents.where(first_name: "Bob").first.update(
        needed_assistance: "no",
        passed_away: "no"
      )
      intake.dependents.where(first_name: "Wendy").first.update(
        needed_assistance: "yes",
        passed_away: "no"
      )

      intake.dependents.reload
    end

    has_prior_last_names { "yes" }
    prior_last_names { "Schitt, Creek" }

    tribal_member { "yes" }
    tribal_wages_amount { 1000 }

    armed_forces_member { "no" }

    charitable_contributions { "no" }

    primary_state_id {
      create :state_id,
             id_type: 'driver_license',
             id_number: '123456',
             state: 'AZ',
             issue_date: Date.new(2020, 1, 1),
             expiration_date: Date.new(2027, 1, 1),
             first_three_doc_num: nil
    }

    spouse_state_id {
      create :state_id,
             id_type: 'dmv_bmv',
             id_number: '654321',
             state: 'MN',
             issue_date: Date.new(2021, 1, 1),
             expiration_date: Date.new(2028, 1, 1),
             first_three_doc_num: nil
    }

    payment_or_deposit_type { "direct_deposit" }
    bank_name { "Canvas Credit union" }
    account_type { "checking" }
    routing_number { "302075830" }
    account_number { "123456" }
  end

  factory "leslie", class: StateFileAzIntake do
    raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml("az_leslie_qss_v2") }
    raw_direct_file_intake_data { StateFile::DirectFileApiResponseSampleService.new.read_json("az_leslie_qss_v2") }

    after(:create) do |intake|
      intake.synchronize_df_dependents_to_database
      intake.synchronize_df_1099_rs_to_database
      intake.synchronize_df_w2s_to_database
      intake.synchronize_filers_to_database
    end

    after(:create) do |intake|
      create(
        :state_file1099_g,
        intake: intake,
        payer_name: "ARIZONA DEPARTMENT OF ECONOMIC SECURITY",
        payer_tin: "270293117",
        payer_street_address: "568 BREWER CIRCLE",
        payer_city: "PHOENIX",
        payer_zip: "85034",
        recipient: "primary",
        recipient_street_address: "321 ANDY STREET",
        recipient_city: "PHOENIX",
        recipient_zip: "85034",
        unemployment_compensation_amount: 10000,
        federal_income_tax_withheld_amount: 10,
        state_identification_number: "123456",
        state_income_tax_withheld_amount: 10,
        )
    end

    has_prior_last_names { "no" }

    tribal_member { "no" }

    armed_forces_member { "yes" }
    armed_forces_wages_amount { 5000 }

    charitable_contributions { "no" }

    payment_or_deposit_type { "mail" }
  end

  factory "martha", class: StateFileAzIntake do
    raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml("az_martha_v2") }
    raw_direct_file_intake_data { StateFile::DirectFileApiResponseSampleService.new.read_json("az_martha_v2") }

    after(:create) do |intake|
      intake.synchronize_df_dependents_to_database
      intake.synchronize_df_1099_rs_to_database
      intake.synchronize_df_w2s_to_database
      intake.synchronize_filers_to_database
    end

    has_prior_last_names { "no" }

    tribal_member { "no" }

    armed_forces_member { "no" }

    charitable_contributions { "yes" }
    charitable_cash_amount { 100 }
    charitable_noncash_amount { 100 }

    payment_or_deposit_type { "direct_deposit" }
    bank_name { "canvas credit union" }
    account_type { "savings" }
    routing_number { "302075830" }
    account_number { "123456" }

    date_electronic_withdrawal { "2024-04-15" }
    withdraw_amount { 356 }
  end

  factory "rory", class: StateFileAzIntake do
    raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml("az_rory_claimedasdep_v2") }
    raw_direct_file_intake_data { StateFile::DirectFileApiResponseSampleService.new.read_json("az_rory_claimedasdep_v2") }

    after(:create) do |intake|
      intake.synchronize_df_dependents_to_database
      intake.synchronize_df_1099_rs_to_database
      intake.synchronize_df_w2s_to_database
      intake.synchronize_filers_to_database
    end

    has_prior_last_names { "no" }

    tribal_member { "no" }

    armed_forces_member { "no" }

    charitable_contributions { "no" }

    payment_or_deposit_type { "mail" }
  end
end