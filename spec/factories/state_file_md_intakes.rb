# == Schema Information
#
# Table name: state_file_md_intakes
#
#  id                                       :bigint           not null, primary key
#  account_number                           :string
#  account_type                             :integer          default("unfilled"), not null
#  bank_name                                :string
#  city                                     :string
#  confirmed_permanent_address              :integer          default("unfilled"), not null
#  consented_to_terms_and_conditions        :integer          default("unfilled"), not null
#  contact_preference                       :integer          default("unfilled"), not null
#  current_sign_in_at                       :datetime
#  current_sign_in_ip                       :inet
#  current_step                             :string
#  date_electronic_withdrawal               :date
#  df_data_import_failed_at                 :datetime
#  df_data_imported_at                      :datetime
#  eligibility_filing_status_mfj            :integer          default("unfilled"), not null
#  eligibility_home_different_areas         :integer          default("unfilled"), not null
#  eligibility_homebuyer_withdrawal         :integer          default("unfilled"), not null
#  eligibility_homebuyer_withdrawal_mfj     :integer          default("unfilled"), not null
#  eligibility_lived_in_state               :integer          default("unfilled"), not null
#  eligibility_out_of_state_income          :integer          default("unfilled"), not null
#  email_address                            :citext
#  email_address_verified_at                :datetime
#  failed_attempts                          :integer          default(0), not null
#  federal_return_status                    :string
#  hashed_ssn                               :string
#  last_sign_in_at                          :datetime
#  last_sign_in_ip                          :inet
#  locale                                   :string           default("en")
#  locked_at                                :datetime
#  message_tracker                          :jsonb
#  payment_or_deposit_type                  :integer          default("unfilled"), not null
#  permanent_address_outside_md             :integer          default("unfilled"), not null
#  permanent_apartment                      :string
#  permanent_city                           :string
#  permanent_street                         :string
#  permanent_zip                            :string
#  phone_number                             :string
#  phone_number_verified_at                 :datetime
#  political_subdivision                    :string
#  primary_birth_date                       :date
#  primary_esigned                          :integer          default("unfilled"), not null
#  primary_esigned_at                       :datetime
#  primary_first_name                       :string
#  primary_last_name                        :string
#  primary_middle_initial                   :string
#  primary_signature                        :string
#  primary_signature_pin                    :text
#  primary_ssn                              :string
#  primary_student_loan_interest_ded_amount :decimal(12, 2)   default(0.0), not null
#  primary_suffix                           :string
#  raw_direct_file_data                     :text
#  raw_direct_file_intake_data              :jsonb
#  referrer                                 :string
#  residence_county                         :string
#  routing_number                           :string
#  sign_in_count                            :integer          default(0), not null
#  source                                   :string
#  spouse_birth_date                        :date
#  spouse_esigned                           :integer          default("unfilled"), not null
#  spouse_esigned_at                        :datetime
#  spouse_first_name                        :string
#  spouse_last_name                         :string
#  spouse_middle_initial                    :string
#  spouse_signature_pin                     :text
#  spouse_ssn                               :string
#  spouse_student_loan_interest_ded_amount  :decimal(12, 2)   default(0.0), not null
#  spouse_suffix                            :string
#  street_address                           :string
#  subdivision_code                         :string
#  unfinished_intake_ids                    :text             default([]), is an Array
#  unsubscribed_from_email                  :boolean          default(FALSE), not null
#  withdraw_amount                          :decimal(12, 2)
#  zip_code                                 :string
#  created_at                               :datetime         not null
#  updated_at                               :datetime         not null
#  federal_submission_id                    :string
#  primary_state_id_id                      :bigint
#  spouse_state_id_id                       :bigint
#  visitor_id                               :string
#
# Indexes
#
#  index_state_file_md_intakes_on_email_address        (email_address)
#  index_state_file_md_intakes_on_hashed_ssn           (hashed_ssn)
#  index_state_file_md_intakes_on_primary_state_id_id  (primary_state_id_id)
#  index_state_file_md_intakes_on_spouse_state_id_id   (spouse_state_id_id)
#
FactoryBot.define do
  factory :state_file_md_intake do
    transient do
      filing_status { 'single' }
    end

    raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml("md_minimal") }
    primary_first_name { "Mary" }
    primary_middle_initial { "A" }
    primary_last_name { "Lando" }
    primary_birth_date { Date.new(1950, 01, 01) } # matches the bday in md_minimal.json

    after(:build) do |intake, evaluator|
      numeric_status = {
        single: 1,
        married_filing_jointly: 2,
        married_filing_separately: 3,
        head_of_household: 4,
        qualifying_widow: 5,
        dependent: 6,
      }[evaluator.filing_status.to_sym] || evaluator.filing_status
      intake.direct_file_data.filing_status = numeric_status
      intake.raw_direct_file_data = intake.direct_file_data.to_s
    end


    trait :with_1099_rs_synced do
      after(:create, &:synchronize_df_1099_rs_to_database)
    end

    trait :with_w2s_synced do
      after(:create, &:synchronize_df_w2s_to_database)
    end


    trait :with_w2s_synced do
      after(:create, &:synchronize_df_w2s_to_database)
    end

    trait :with_spouse do
      raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml("md_nate_mfj") }
      filing_status { 'married_filing_jointly' }

      spouse_first_name { "Marty" }
      spouse_middle_initial { "B" }
      spouse_last_name { "Lando" }
      spouse_birth_date { MultiTenantService.statefile.end_of_current_tax_year - 40 }
    end

    trait :with_senior_spouse do
      raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml("md_nate_mfj") }
      filing_status { 'married_filing_jointly' }

      spouse_first_name { "Marty" }
      spouse_middle_initial { "B" }
      spouse_last_name { "Lando" }
      spouse_birth_date { MultiTenantService.statefile.end_of_current_tax_year - 70 }
    end

    trait :df_data_2_w2s do
      raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml('md_zeus_two_w2s') }
    end

    trait :df_data_many_w2s do
      raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml('md_zeus_many_w2s') }
    end

    trait :head_of_household do
      filing_status { 'head_of_household' }
      raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml('md_shelby_hoh') }
    end

    trait :qualifying_widow do
      filing_status { 'qualifying_widow' }
      raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml('md_laney_qss') }
    end

    trait :claimed_as_dependent do
      raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml('md_riley_claimedasdep') }
    end

    trait :df_data_1099_int do
      raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml('md_todd_1099_int') }
      raw_direct_file_intake_data { StateFile::DirectFileApiResponseSampleService.new.read_json('md_todd_1099_int') }
    end
  end
end
