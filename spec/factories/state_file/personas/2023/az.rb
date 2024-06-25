FactoryBot.define do
  factory "johnny", class: StateFileAzIntake do
    raw_direct_file_data { StateFile::XmlReturnSampleService.new.read("az_johnny_mfj_8_deps") }
    primary_first_name { "Johnny" }
    primary_middle_initial { "L" }
    primary_last_name { "Rose" }
    primary_suffix { "SR" }
    primary_birth_date { "1975-01-01" }

    spouse_first_name { "Moira" }
    spouse_last_name { "O'Hara" }
    spouse_birth_date { "1975-02-02" }

    after(:create) do |intake|
      intake.synchronize_df_dependents_to_database

      intake.dependents.where(first_name: "David").first.update(
        dob: Date.new(2015, 1, 1),
        relationship: "DAUGHTER",
        months_in_home: 12
      )
      intake.dependents.where(first_name: "Twyla").first.update(
        dob: Date.new(2017, 1, 2),
        relationship: "NEPHEW",
        months_in_home: 7
      )
      intake.dependents.where(first_name: "Alexis").first.update(
        dob: Date.new(2019, 2, 2),
        relationship: "DAUGHTER",
        months_in_home: 12
      )
      intake.dependents.where(first_name: "Stevie").first.update(
        dob: Date.new(2021, 5, 5),
        relationship: "DAUGHTER",
        months_in_home: 8
      )
      intake.dependents.where(first_name: "Roland").first.update(
        dob: Date.new(1960, 6, 6),
        relationship: "PARENT",
        months_in_home: 12
      )
      intake.dependents.where(first_name: "Ronnie").first.update(
        dob: Date.new(1960, 7, 7),
        relationship: "PARENT",
        months_in_home: 12
      )
      intake.dependents.where(first_name: "Bob").first.update(
        dob: Date.new(1940, 3, 3),
        relationship: "GRANDPARENT",
        months_in_home: 7,
        needed_assistance: "no",
        passed_away: "no"
      )
      intake.dependents.where(first_name: "Wendy").first.update(
        dob: Date.new(1940, 4, 4),
        relationship: "GRANDPARENT",
        months_in_home: 12,
        needed_assistance: "yes",
        passed_away: "no"
      )
      intake.dependents.reload
    end

    has_prior_last_names { "yes" }
    prior_last_names { "Schitt, Creek" }

    tribal_member { "yes" }
    tribal_wages { 1000 }

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

    federal_submission_id { "12345202201011234570" }
  end
end