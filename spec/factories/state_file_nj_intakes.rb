# == Schema Information
#
# Table name: state_file_nj_intakes
#
#  id                                                     :bigint           not null, primary key
#  account_number                                         :string
#  account_type                                           :integer          default("unfilled"), not null
#  bank_name                                              :string
#  claimed_as_dep                                         :integer
#  claimed_as_eitc_qualifying_child                       :integer          default("unfilled"), not null
#  consented_to_terms_and_conditions                      :integer          default("unfilled"), not null
#  contact_preference                                     :integer          default("unfilled"), not null
#  county                                                 :string
#  current_sign_in_at                                     :datetime
#  current_sign_in_ip                                     :inet
#  current_step                                           :string
#  date_electronic_withdrawal                             :date
#  df_data_import_failed_at                               :datetime
#  df_data_imported_at                                    :datetime
#  eligibility_lived_in_state                             :integer          default("unfilled"), not null
#  eligibility_out_of_state_income                        :integer          default("unfilled"), not null
#  email_address                                          :citext
#  email_address_verified_at                              :datetime
#  failed_attempts                                        :integer          default(0), not null
#  fed_taxable_income                                     :integer
#  fed_wages                                              :integer
#  federal_return_status                                  :string
#  hashed_ssn                                             :string
#  homeowner_home_subject_to_property_taxes               :integer          default("unfilled"), not null
#  homeowner_main_home_multi_unit                         :integer          default("unfilled"), not null
#  homeowner_main_home_multi_unit_max_four_one_commercial :integer          default("unfilled"), not null
#  homeowner_more_than_one_main_home_in_nj                :integer          default("unfilled"), not null
#  homeowner_same_home_spouse                             :integer          default("unfilled"), not null
#  homeowner_shared_ownership_not_spouse                  :integer          default("unfilled"), not null
#  household_rent_own                                     :integer          default("unfilled"), not null
#  last_sign_in_at                                        :datetime
#  last_sign_in_ip                                        :inet
#  locale                                                 :string           default("en")
#  locked_at                                              :datetime
#  medical_expenses                                       :decimal(12, 2)   default(0.0), not null
#  message_tracker                                        :jsonb
#  municipality_code                                      :string
#  municipality_name                                      :string
#  payment_or_deposit_type                                :integer          default("unfilled"), not null
#  permanent_apartment                                    :string
#  permanent_city                                         :string
#  permanent_street                                       :string
#  permanent_zip                                          :string
#  phone_number                                           :string
#  phone_number_verified_at                               :datetime
#  primary_birth_date                                     :date
#  primary_disabled                                       :integer          default("unfilled"), not null
#  primary_esigned                                        :integer          default("unfilled"), not null
#  primary_esigned_at                                     :datetime
#  primary_first_name                                     :string
#  primary_last_name                                      :string
#  primary_middle_initial                                 :string
#  primary_signature                                      :string
#  primary_ssn                                            :string
#  primary_suffix                                         :string
#  primary_veteran                                        :integer          default("unfilled"), not null
#  property_tax_paid                                      :decimal(12, 2)
#  raw_direct_file_data                                   :text
#  raw_direct_file_intake_data                            :jsonb
#  referrer                                               :string
#  rent_paid                                              :decimal(12, 2)
#  routing_number                                         :string
#  sales_use_tax                                          :decimal(12, 2)
#  sales_use_tax_calculation_method                       :integer          default("unfilled"), not null
#  sign_in_count                                          :integer          default(0), not null
#  source                                                 :string
#  spouse_birth_date                                      :date
#  spouse_claimed_as_eitc_qualifying_child                :integer          default("unfilled"), not null
#  spouse_disabled                                        :integer          default("unfilled"), not null
#  spouse_esigned                                         :integer          default("unfilled"), not null
#  spouse_esigned_at                                      :datetime
#  spouse_first_name                                      :string
#  spouse_last_name                                       :string
#  spouse_middle_initial                                  :string
#  spouse_ssn                                             :string
#  spouse_suffix                                          :string
#  spouse_veteran                                         :integer          default("unfilled"), not null
#  tenant_access_kitchen_bath                             :integer          default("unfilled"), not null
#  tenant_building_multi_unit                             :integer          default("unfilled"), not null
#  tenant_home_subject_to_property_taxes                  :integer          default("unfilled"), not null
#  tenant_more_than_one_main_home_in_nj                   :integer          default("unfilled"), not null
#  tenant_same_home_spouse                                :integer          default("unfilled"), not null
#  tenant_shared_rent_not_spouse                          :integer          default("unfilled"), not null
#  unfinished_intake_ids                                  :text             default([]), is an Array
#  unsubscribed_from_email                                :boolean          default(FALSE), not null
#  untaxed_out_of_state_purchases                         :integer          default("unfilled"), not null
#  withdraw_amount                                        :integer
#  created_at                                             :datetime         not null
#  updated_at                                             :datetime         not null
#  federal_submission_id                                  :string
#  primary_state_id_id                                    :bigint
#  spouse_state_id_id                                     :bigint
#  visitor_id                                             :string
#
# Indexes
#
#  index_state_file_nj_intakes_on_email_address        (email_address)
#  index_state_file_nj_intakes_on_hashed_ssn           (hashed_ssn)
#  index_state_file_nj_intakes_on_primary_state_id_id  (primary_state_id_id)
#  index_state_file_nj_intakes_on_spouse_state_id_id   (spouse_state_id_id)
#
FactoryBot.define do
  factory :state_file_nj_intake do
    transient do
      filing_status { 'single' }
    end

    raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml("nj_zeus_one_dep") }
    raw_direct_file_intake_data { StateFile::DirectFileApiResponseSampleService.new.read_json('nj_zeus_one_dep') }
    
    after(:build) do |intake, evaluator|
      intake.municipality_code = "0101"
      numeric_status = {
        single: 1,
        married_filing_jointly: 2,
        married_filing_separately: 3,
        head_of_household: 4,
        qualifying_widow: 5,
        }[evaluator.filing_status.to_sym] || evaluator.filing_status
      intake.direct_file_data.filing_status = numeric_status
      intake.direct_file_data.primary_ssn = evaluator.primary_ssn || intake.direct_file_data.primary_ssn
      intake.direct_file_data.spouse_ssn = evaluator.spouse_ssn || intake.direct_file_data.spouse_ssn
      intake.raw_direct_file_data = intake.direct_file_data.to_s
    end
      
    after(:create) do |intake, evaluator|
      intake.synchronize_filers_to_database
      supplied_attributes = evaluator.instance_variable_get(:@cached_attributes)
      overrides = {}
      supplied_attributes.each do |key, _value|
        supplied_attribute = supplied_attributes[key]
        overrides[key] = supplied_attribute if intake.has_attribute?(key)
      end
      intake.update(overrides)

      intake.synchronize_df_w2s_to_database
      intake.synchronize_df_dependents_to_database
      intake.dependents.each_with_index do |dependent, i|
        dependent.update(dob: i.years.ago)
      end
    end

    trait :df_data_2_w2s do
      raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml('nj_zeus_two_w2s') }
      raw_direct_file_intake_data { StateFile::DirectFileApiResponseSampleService.new.read_json('nj_zeus_two_w2s') }
    end

    trait :df_data_many_w2s do
      raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml('nj_zeus_many_w2s') }
      raw_direct_file_intake_data { StateFile::DirectFileApiResponseSampleService.new.read_json('nj_zeus_many_w2s') }
    end

    trait :df_data_minimal do
      raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml('nj_minimal') }
      raw_direct_file_intake_data { StateFile::DirectFileApiResponseSampleService.new.read_json('nj_minimal') }
    end

    trait :df_data_many_deps do
      raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml('nj_zeus_many_deps') }
      raw_direct_file_intake_data { StateFile::DirectFileApiResponseSampleService.new.read_json('nj_zeus_many_deps') }
    end

    trait :df_data_one_dep do
      raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml('nj_zeus_one_dep') }
      raw_direct_file_intake_data { StateFile::DirectFileApiResponseSampleService.new.read_json('nj_zeus_one_dep') }
    end

    trait :df_data_two_deps do
      raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml('nj_zeus_two_deps') }
      raw_direct_file_intake_data { StateFile::DirectFileApiResponseSampleService.new.read_json('nj_zeus_two_deps') }
    end

    trait :df_data_mfj do
      filing_status { "married_filing_jointly" }
      raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml('nj_married_filing_jointly') }
      raw_direct_file_intake_data { StateFile::DirectFileApiResponseSampleService.new.read_json('nj_married_filing_jointly') }
    end

    trait :df_data_mfs do
      filing_status { "married_filing_separately" }
      raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml('nj_married_filing_separately') }
      raw_direct_file_intake_data { StateFile::DirectFileApiResponseSampleService.new.read_json('nj_married_filing_separately') }
    end

    trait :df_data_exempt_interest do
      raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml('nj_exempt_interest_over_10k') }
      raw_direct_file_intake_data { StateFile::DirectFileApiResponseSampleService.new.read_json('nj_exempt_interest_over_10k') }
    end

    trait :df_data_investment_income_12k do
      raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml('nj_investment_income_12k') }
      raw_direct_file_intake_data { StateFile::DirectFileApiResponseSampleService.new.read_json('nj_investment_income_12k') }
    end

    trait :married_filing_jointly do
      filing_status { "married_filing_jointly" }
      spouse_birth_date { Date.new(1990, 1, 1) }
      spouse_ssn { "123456789" }
    end

    trait :head_of_household do
      filing_status { "head_of_household" }
    end

    trait :qualifying_widow do
      filing_status { "qualifying_widow" }
    end

    trait :married_filing_separately do
      transient do
        filing_status { 'married_filing_separately' }
        spouse_ssn { "123456789" }
        spouse_occupation { "Lawyer" }
      end

      spouse_birth_date { Date.new(1990, 1, 1) }
      spouse_first_name { "Spousel" }
      spouse_last_name { "Testerson" }
      spouse_middle_initial { "T" }
    end

    trait :primary_over_65 do
      primary_birth_date { Date.new(1900, 1, 1) }
    end

    trait :mfj_spouse_over_65 do
      filing_status { "married_filing_jointly" }
      spouse_birth_date { Date.new(1900, 1, 1) }
      spouse_ssn { "123456789" }
    end

    trait :primary_blind do
      after(:build) do |intake|
        intake.direct_file_data.primary_blind
      end
    end

    trait :spouse_blind do
      after(:build) do |intake|
        intake.direct_file_data.spouse_blind
      end
    end

    trait :primary_disabled do
      primary_disabled { "yes" }
    end

    trait :spouse_disabled do
      spouse_disabled { "yes" }
    end

    trait :fed_credit_for_child_and_dependent_care do
      after(:build) do |intake|
        intake.direct_file_data.fed_credit_for_child_and_dependent_care_amount = 1000
      end
    end

    trait :primary_veteran do
      primary_veteran { "yes" }
    end

    trait :spouse_veteran do
      spouse_veteran { "yes" }
    end

    trait :claimed_as_eitc_qualifying_child do
      claimed_as_eitc_qualifying_child { "yes" }
    end

    trait :spouse_claimed_as_eitc_qualifying_child do
      spouse_claimed_as_eitc_qualifying_child { "yes" }
    end

    trait :claimed_as_eitc_qualifying_child_no do
      claimed_as_eitc_qualifying_child { "no" }
    end

    trait :spouse_claimed_as_eitc_qualifying_child_no do
      spouse_claimed_as_eitc_qualifying_child { "no" }
    end
  end
end
