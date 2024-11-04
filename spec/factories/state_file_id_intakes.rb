# == Schema Information
#
# Table name: state_file_id_intakes
#
#  id                                             :bigint           not null, primary key
#  account_number                                 :string
#  account_type                                   :integer          default("unfilled"), not null
#  bank_name                                      :string
#  consented_to_terms_and_conditions              :integer          default("unfilled"), not null
#  contact_preference                             :integer          default("unfilled"), not null
#  current_sign_in_at                             :datetime
#  current_sign_in_ip                             :inet
#  current_step                                   :string
#  date_electronic_withdrawal                     :date
#  df_data_import_failed_at                       :datetime
#  df_data_imported_at                            :datetime
#  donate_grocery_credit                          :integer          default("unfilled"), not null
#  eligibility_emergency_rental_assistance        :integer          default("unfilled"), not null
#  eligibility_withdrew_msa_fthb                  :integer          default("unfilled"), not null
#  email_address                                  :citext
#  email_address_verified_at                      :datetime
#  failed_attempts                                :integer          default(0), not null
#  federal_return_status                          :string
#  has_health_insurance_premium                   :integer          default("unfilled"), not null
#  has_unpaid_sales_use_tax                       :integer          default("unfilled"), not null
#  hashed_ssn                                     :string
#  health_insurance_paid_amount                   :decimal(12, 2)
#  household_has_grocery_credit_ineligible_months :integer          default("unfilled"), not null
#  last_sign_in_at                                :datetime
#  last_sign_in_ip                                :inet
#  locale                                         :string           default("en")
#  locked_at                                      :datetime
#  message_tracker                                :jsonb
#  payment_or_deposit_type                        :integer          default("unfilled"), not null
#  phone_number                                   :string
#  phone_number_verified_at                       :datetime
#  primary_birth_date                             :date
#  primary_esigned                                :integer          default("unfilled"), not null
#  primary_esigned_at                             :datetime
#  primary_first_name                             :string
#  primary_has_grocery_credit_ineligible_months   :integer          default("unfilled"), not null
#  primary_last_name                              :string
#  primary_middle_initial                         :string
#  primary_months_ineligible_for_grocery_credit   :integer          default(0)
#  primary_suffix                                 :string
#  raw_direct_file_data                           :text
#  raw_direct_file_intake_data                    :jsonb
#  referrer                                       :string
#  routing_number                                 :integer
#  sign_in_count                                  :integer          default(0), not null
#  source                                         :string
#  spouse_birth_date                              :date
#  spouse_esigned                                 :integer          default("unfilled"), not null
#  spouse_esigned_at                              :datetime
#  spouse_first_name                              :string
#  spouse_has_grocery_credit_ineligible_months    :integer          default("unfilled"), not null
#  spouse_last_name                               :string
#  spouse_middle_initial                          :string
#  spouse_months_ineligible_for_grocery_credit    :integer          default(0)
#  spouse_suffix                                  :string
#  total_purchase_amount                          :decimal(12, 2)
#  unsubscribed_from_email                        :boolean          default(FALSE), not null
#  withdraw_amount                                :integer
#  created_at                                     :datetime         not null
#  updated_at                                     :datetime         not null
#  federal_submission_id                          :string
#  primary_state_id_id                            :bigint
#  spouse_state_id_id                             :bigint
#  visitor_id                                     :string
#
# Indexes
#
#  index_state_file_id_intakes_on_email_address        (email_address)
#  index_state_file_id_intakes_on_hashed_ssn           (hashed_ssn)
#  index_state_file_id_intakes_on_primary_state_id_id  (primary_state_id_id)
#  index_state_file_id_intakes_on_spouse_state_id_id   (spouse_state_id_id)
#
FactoryBot.define do
  factory :minimal_state_file_id_intake, class: "StateFileIdIntake"
  factory :state_file_id_intake do
    raw_direct_file_data { File.read(Rails.root.join('app', 'controllers', 'state_file', 'questions', 'df_return_sample.xml')) }
    raw_direct_file_intake_data { File.read(Rails.root.join('app', 'controllers', 'state_file', 'questions', 'df_return_sample.json')) }

    transient do
      filing_status { "single" }

      primary_birth_date { nil }
      primary_first_name { nil }
      primary_middle_initial { nil }
      primary_last_name { nil }

      spouse_birth_date { nil }
      spouse_first_name { nil }
      spouse_middle_initial { nil }
      spouse_last_name { nil }
    end

    after(:build) do |intake, evaluator|
      numeric_status = {
        single: 1,
        married_filing_jointly: 2,
        married_filing_separately: 3,
        head_of_household: 4,
        qualifying_widow: 5,
      }[evaluator.filing_status.to_sym] || evaluator.filing_status
      intake.direct_file_data.filing_status = numeric_status
      intake.raw_direct_file_data = intake.direct_file_data.to_s

      intake.direct_file_json_data.primary_filer.dob = evaluator.primary_birth_date if evaluator.primary_birth_date
      intake.direct_file_json_data.primary_filer.first_name = evaluator.primary_first_name if evaluator.primary_first_name
      intake.direct_file_json_data.primary_filer.middle_initial = evaluator.primary_middle_initial if evaluator.primary_middle_initial
      intake.direct_file_json_data.primary_filer.last_name = evaluator.primary_last_name if evaluator.primary_last_name

      if intake.direct_file_json_data.spouse_filer.present?
        intake.direct_file_json_data.spouse_filer.dob = evaluator.spouse_birth_date if evaluator.spouse_birth_date
        intake.direct_file_json_data.spouse_filer.first_name = evaluator.spouse_first_name if evaluator.spouse_first_name
        intake.direct_file_json_data.spouse_filer.middle_initial = evaluator.spouse_middle_initial if evaluator.spouse_middle_initial
        intake.direct_file_json_data.spouse_filer.last_name = evaluator.spouse_last_name if evaluator.spouse_last_name
      else
        # this is necessary because we occasionally use xmls that include a spouse with a json without a spouse,
        # or change an intake's filing status and add spouse info after loading an xml without one
        intake.spouse_birth_date = evaluator.spouse_birth_date if evaluator.spouse_birth_date
        intake.spouse_first_name = evaluator.spouse_first_name if evaluator.spouse_first_name
        intake.spouse_middle_initial = evaluator.spouse_middle_initial if evaluator.spouse_middle_initial
        intake.spouse_last_name = evaluator.spouse_last_name if evaluator.spouse_last_name
      end

      intake.raw_direct_file_intake_data = intake.direct_file_json_data.to_json
    end

    after(:create) do |intake|
      intake.synchronize_filers_to_database
    end

    trait :with_w2s_synced do
      after(:create, &:synchronize_df_w2s_to_database)
    end

    #TODO : Use the personas we have for ID instead of df_return_sample.xml later because we have ID xmls and the df_return_sample is a fake NY one

    trait :single_filer_with_json do
      raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml('id_lana_single') }
      raw_direct_file_intake_data { StateFile::DirectFileApiResponseSampleService.new.read_json('id_lana_single') }

    end

    trait :mfj_filer_with_json do
      filing_status { "married_filing_jointly" }
      raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml('id_paul_mfj') }
      raw_direct_file_intake_data { StateFile::DirectFileApiResponseSampleService.new.read_json('id_paul_mfj') }
    end

    trait :with_dependents do
      raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml('id_ernest_hoh') }
      raw_direct_file_intake_data { StateFile::DirectFileApiResponseSampleService.new.read_json('id_ernest_hoh') }

      after(:create) do |intake|
        intake.synchronize_df_dependents_to_database
      end
    end

    trait :df_data_1099_int do
      primary_first_name { "Tim" }
      primary_last_name { "Interest" }
      raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml('id_tim_1099_int') }
      raw_direct_file_intake_data { StateFile::DirectFileApiResponseSampleService.new.read_json('id_tim_1099_int') }
    end
  end
end
