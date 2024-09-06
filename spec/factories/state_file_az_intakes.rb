# == Schema Information
#
# Table name: state_file_az_intakes
#
#  id                                          :bigint           not null, primary key
#  account_number                              :string
#  account_type                                :integer
#  armed_forces_member                         :integer          default("unfilled"), not null
#  armed_forces_wages                          :integer
#  bank_name                                   :string
#  charitable_cash                             :integer          default(0)
#  charitable_contributions                    :integer          default("unfilled"), not null
#  charitable_noncash                          :integer          default(0)
#  consented_to_terms_and_conditions           :integer          default("unfilled"), not null
#  contact_preference                          :integer          default("unfilled"), not null
#  current_sign_in_at                          :datetime
#  current_sign_in_ip                          :inet
#  current_step                                :string
#  date_electronic_withdrawal                  :date
#  df_data_import_failed_at                    :datetime
#  df_data_imported_at                         :datetime
#  eligibility_529_for_non_qual_expense        :integer          default("unfilled"), not null
#  eligibility_lived_in_state                  :integer          default("unfilled"), not null
#  eligibility_married_filing_separately       :integer          default("unfilled"), not null
#  eligibility_out_of_state_income             :integer          default("unfilled"), not null
#  email_address                               :citext
#  email_address_verified_at                   :datetime
#  failed_attempts                             :integer          default(0), not null
#  federal_return_status                       :string
#  has_prior_last_names                        :integer          default("unfilled"), not null
#  hashed_ssn                                  :string
#  household_excise_credit_claimed             :integer          default("unfilled"), not null
#  household_excise_credit_claimed_amt         :integer
#  last_sign_in_at                             :datetime
#  last_sign_in_ip                             :inet
#  locale                                      :string           default("en")
#  locked_at                                   :datetime
#  made_az321_contributions                    :integer          default("unfilled"), not null
#  message_tracker                             :jsonb
#  payment_or_deposit_type                     :integer          default("unfilled"), not null
#  phone_number                                :string
#  phone_number_verified_at                    :datetime
#  primary_birth_date                          :date
#  primary_esigned                             :integer          default("unfilled"), not null
#  primary_esigned_at                          :datetime
#  primary_first_name                          :string
#  primary_last_name                           :string
#  primary_middle_initial                      :string
#  primary_received_pension                    :integer          default("unfilled"), not null
#  primary_received_pension_amount             :decimal(12, 2)
#  primary_suffix                              :string
#  primary_was_incarcerated                    :integer          default("unfilled"), not null
#  prior_last_names                            :string
#  raw_direct_file_data                        :text
#  received_military_retirement_payment        :integer          default("unfilled"), not null
#  received_military_retirement_payment_amount :decimal(12, 2)
#  referrer                                    :string
#  routing_number                              :string
#  sign_in_count                               :integer          default(0), not null
#  source                                      :string
#  spouse_birth_date                           :date
#  spouse_esigned                              :integer          default("unfilled"), not null
#  spouse_esigned_at                           :datetime
#  spouse_first_name                           :string
#  spouse_last_name                            :string
#  spouse_middle_initial                       :string
#  spouse_received_pension                     :integer          default("unfilled"), not null
#  spouse_received_pension_amount              :decimal(12, 2)
#  spouse_suffix                               :string
#  spouse_was_incarcerated                     :integer          default("unfilled"), not null
#  ssn_no_employment                           :integer          default("unfilled"), not null
#  tribal_member                               :integer          default("unfilled"), not null
#  tribal_wages                                :integer
#  unfinished_intake_ids                       :text             default([]), is an Array
#  unsubscribed_from_email                     :boolean          default(FALSE), not null
#  was_incarcerated                            :integer          default("unfilled"), not null
#  withdraw_amount                             :integer
#  created_at                                  :datetime         not null
#  updated_at                                  :datetime         not null
#  federal_submission_id                       :string
#  primary_state_id_id                         :bigint
#  spouse_state_id_id                          :bigint
#  visitor_id                                  :string
#
# Indexes
#
#  index_state_file_az_intakes_on_email_address        (email_address)
#  index_state_file_az_intakes_on_hashed_ssn           (hashed_ssn)
#  index_state_file_az_intakes_on_primary_state_id_id  (primary_state_id_id)
#  index_state_file_az_intakes_on_spouse_state_id_id   (spouse_state_id_id)
#
FactoryBot.define do
  factory :minimal_state_file_az_intake, class: "StateFileAzIntake"

  factory :state_file_az_intake do
    transient do
      filing_status { 'single' }
      hoh_qualifying_person_name { '' }
    end

    raw_direct_file_data { File.read(Rails.root.join('app', 'controllers', 'state_file', 'questions', 'df_return_sample.xml')) }
    primary_first_name { "Ariz" }
    primary_last_name { "Onian" }
    state_file_analytics { StateFileAnalytics.create }

    after(:build) do |intake, evaluator|
      numeric_status = {
        single: 1,
        married_filing_jointly: 2,
        married_filing_separately: 3,
        head_of_household: 4,
        qualifying_widow: 5,
      }[evaluator.filing_status.to_sym] || evaluator.filing_status
      intake.direct_file_data.filing_status = numeric_status
      intake.direct_file_data.hoh_qualifying_person_name = evaluator.hoh_qualifying_person_name
      intake.direct_file_data.fed_agi = 120000
      intake.direct_file_data.fed_w2_state = "AZ"
      intake.raw_direct_file_data = intake.direct_file_data.to_s
    end

    trait :with_1099r_subtractions do
      received_military_retirement_payment { "yes" }
      primary_received_pension { "yes" }
      spouse_received_pension { "yes" }
      received_military_retirement_payment_amount { 100 }
      primary_received_pension_amount { 200 }
      spouse_received_pension_amount { 300 }
    end

    trait :with_az321_contributions do
      made_az321_contributions { "yes" }

      after(:create) do |intake|
        create :az321_contribution,
               amount: 505.90,
               state_file_az_intake: intake,
               charity_code: "22345",
               charity_name: "Heartland",
               date_of_contribution: Date.parse("August 22 2023")
        create :az321_contribution,
               amount: 234.89,
               state_file_az_intake: intake,
               charity_code: "25544",
               charity_name: "Crumbs and Whiskers",
               date_of_contribution: Date.parse("July 31 2023")
        create :az321_contribution,
               amount: 234.89,
               state_file_az_intake: intake,
               charity_code: "25999",
               charity_name: "The Flying Seagull Project",
               date_of_contribution: Date.parse("June 1 2023")
        create :az321_contribution,
               amount: 234.89,
               state_file_az_intake: intake,
               charity_code: "27661",
               charity_name: "Frogs Are Green",
               date_of_contribution: Date.parse("January 15 2023")
      end
    end

    trait :with_az322_contributions do
      after(:build) do |intake|
        create(:az322_contribution,
               date_of_contribution: '2023-03-04',
               ctds_code: '123456789',
               school_name: 'School A',
               district_name: 'District A',
               amount: 100,
               state_file_az_intake: intake)
        create(:az322_contribution,
               date_of_contribution: '2023-02-01',
               ctds_code: '123456789',
               school_name: 'School B',
               district_name: 'District B',
               amount: 200,
               state_file_az_intake: intake)
        create(:az322_contribution,
               date_of_contribution: '2023-03-01',
               ctds_code: '123456789',
               school_name: 'School C',
               district_name: 'District C',
               amount: 300,
               state_file_az_intake: intake)
        create(:az322_contribution,
               date_of_contribution: '2023-04-01',
               ctds_code: '123456789',
               school_name: 'School D',
               district_name: 'District D',
               amount: 400,
               state_file_az_intake: intake)
        create(:az322_contribution,
               date_of_contribution: '2023-05-01',
               ctds_code: '123456789',
               school_name: 'School E',
               district_name: 'District E',
               amount: 500,
               state_file_az_intake: intake)
      end
    end

    trait :with_efile_device_infos do
      after(:build) do |intake|
        create :state_file_efile_device_info, :filled, :initial_creation, intake: intake
        create :state_file_efile_device_info, :filled, :submission, intake: intake
      end
    end

    trait :df_data_2_w2s do
      raw_direct_file_data { StateFile::XmlReturnSampleService.new.read('az_superman') }
    end

    trait :df_data_many_w2s do
      raw_direct_file_data { StateFile::XmlReturnSampleService.new.read('az_goldwater') }
    end

    factory :state_file_az_refund_intake do
      after(:build) do |intake, evaluator|
        intake.direct_file_data.fed_agi = 10000
        intake.raw_direct_file_data = intake.direct_file_data.to_s
        intake.payment_or_deposit_type = "direct_deposit"
        intake.account_type = "savings"
        intake.routing_number = 111111111
        intake.account_number = 222222222
      end
    end

    factory :state_file_az_owed_intake do
      after(:build) do |intake, evaluator|
        intake.direct_file_data.fed_agi = 120000
        intake.raw_direct_file_data = intake.direct_file_data.to_s
        intake.payment_or_deposit_type = "direct_deposit"
        intake.account_type = "checking"
        intake.routing_number = 111111111
        intake.account_number = 222222222
        intake.date_electronic_withdrawal = Date.new(2024, 4, 15)
        intake.withdraw_amount = 5
      end
    end

    factory :state_file_az_intake_after_transfer do
      sequence(:hashed_ssn) { |n| "abcdefg12346#{n}" }
    end

    factory :state_file_az_johnny_intake do
      # Details of this scenario: https://docs.google.com/document/d/1Aq-1Qdna62gUQqzPyYY2CetC-VZWtCqK73LqBYBLINw/edit
      raw_direct_file_data { StateFile::XmlReturnSampleService.new.read('az_johnny_mfj_8_deps') }

      after(:create) do |intake|
        intake.synchronize_df_dependents_to_database

        # Under 17
        intake.dependents.where(first_name: "David").first.update(
          dob: Date.new(2015, 1, 1),
          relationship: "DAUGHTER",
          months_in_home: 12
        )

        # Under 17
        intake.dependents.where(first_name: "Twyla").first.update(
          dob: Date.new(2017, 1, 2),
          relationship: "NEPHEW",
          months_in_home: 7
        )

        # Under 17
        intake.dependents.where(first_name: "Alexis").first.update(
          dob: Date.new(2019, 2, 2),
          relationship: "DAUGHTER",
          months_in_home: 12
        )

        # Under 17
        intake.dependents.where(first_name: "Stevie").first.update(
          dob: Date.new(2021, 5, 5),
          relationship: "DAUGHTER",
          months_in_home: 8
        )

        # Over 17
        intake.dependents.where(first_name: "Roland").first.update(
          dob: Date.new(1960, 6, 6),
          relationship: "PARENT",
          months_in_home: 12
        )

        # Over 17
        intake.dependents.where(first_name: "Ronnie").first.update(
          dob: Date.new(1960, 7, 7),
          relationship: "PARENT",
          months_in_home: 12
        )

        # Over 17 & Over 65, non-qualifying ancestor
        intake.dependents.where(first_name: "Bob").first.update(
          dob: Date.new(1940, 3, 3),
          relationship: "GRANDPARENT",
          months_in_home: 7,
          needed_assistance: "no",
          passed_away: "no"
        )

        # Qualifying ancestor
        intake.dependents.where(first_name: "Wendy").first.update(
          dob: Date.new(1940, 4, 4),
          relationship: "GRANDPARENT",
          months_in_home: 12,
          needed_assistance: "yes",
          passed_away: "no"
        )
        intake.dependents.reload
      end
    end
  end
end
