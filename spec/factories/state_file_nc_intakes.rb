# == Schema Information
#
# Table name: state_file_nc_intakes
#
#  id                                :bigint           not null, primary key
#  account_number                    :string
#  account_type                      :integer          default("unfilled"), not null
#  city                              :string
#  consented_to_sms_terms            :integer          default("unfilled"), not null
#  consented_to_terms_and_conditions :integer          default("unfilled"), not null
#  contact_preference                :integer          default("unfilled"), not null
#  county_during_hurricane_helene    :string
#  current_sign_in_at                :datetime
#  current_sign_in_ip                :inet
#  current_step                      :string
#  date_electronic_withdrawal        :date
#  df_data_import_succeeded_at       :datetime
#  df_data_imported_at               :datetime
#  eligibility_ed_loan_cancelled     :integer          default("no"), not null
#  eligibility_ed_loan_emp_payment   :integer          default("no"), not null
#  eligibility_lived_in_state        :integer          default("unfilled"), not null
#  eligibility_out_of_state_income   :integer          default("unfilled"), not null
#  eligibility_withdrew_529          :integer          default("unfilled"), not null
#  email_address                     :citext
#  email_address_verified_at         :datetime
#  email_notification_opt_in         :integer          default("unfilled"), not null
#  extension_payments_amount         :decimal(12, 2)
#  failed_attempts                   :integer          default(0), not null
#  federal_return_status             :string
#  hashed_ssn                        :string
#  last_sign_in_at                   :datetime
#  last_sign_in_ip                   :inet
#  locale                            :string           default("en")
#  locked_at                         :datetime
#  message_tracker                   :jsonb
#  moved_after_hurricane_helene      :integer          default("unfilled"), not null
#  out_of_country                    :integer          default("unfilled"), not null
#  paid_extension_payments           :integer          default("unfilled"), not null
#  paid_federal_extension_payments   :integer          default("unfilled"), not null
#  payment_or_deposit_type           :integer          default("unfilled"), not null
#  phone_number                      :string
#  phone_number_verified_at          :datetime
#  primary_birth_date                :date
#  primary_esigned                   :integer          default("unfilled"), not null
#  primary_esigned_at                :datetime
#  primary_first_name                :string
#  primary_last_name                 :string
#  primary_middle_initial            :string
#  primary_suffix                    :string
#  primary_veteran                   :integer          default("unfilled"), not null
#  raw_direct_file_data              :text
#  raw_direct_file_intake_data       :jsonb
#  referrer                          :string
#  residence_county                  :string
#  routing_number                    :string
#  sales_use_tax                     :decimal(12, 2)
#  sales_use_tax_calculation_method  :integer          default("unfilled"), not null
#  sign_in_count                     :integer          default(0), not null
#  sms_notification_opt_in           :integer          default("unfilled"), not null
#  source                            :string
#  spouse_birth_date                 :date
#  spouse_death_year                 :integer
#  spouse_esigned                    :integer          default("unfilled"), not null
#  spouse_esigned_at                 :datetime
#  spouse_first_name                 :string
#  spouse_last_name                  :string
#  spouse_middle_initial             :string
#  spouse_suffix                     :string
#  spouse_veteran                    :integer          default("unfilled"), not null
#  ssn                               :string
#  street_address                    :string
#  tribal_member                     :integer          default("unfilled"), not null
#  tribal_wages_amount               :decimal(12, 2)
#  unfinished_intake_ids             :text             default([]), is an Array
#  unsubscribed_from_email           :boolean          default(FALSE), not null
#  untaxed_out_of_state_purchases    :integer          default("unfilled"), not null
#  withdraw_amount                   :integer
#  zip_code                          :string
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  federal_submission_id             :string
#  primary_state_id_id               :bigint
#  spouse_state_id_id                :bigint
#  visitor_id                        :string
#
# Indexes
#
#  index_state_file_nc_intakes_on_hashed_ssn           (hashed_ssn)
#  index_state_file_nc_intakes_on_primary_state_id_id  (primary_state_id_id)
#  index_state_file_nc_intakes_on_spouse_state_id_id   (spouse_state_id_id)
#
FactoryBot.define do
  factory :state_file_nc_intake do
    transient do
      filing_status { 'single' }
    end

    factory :state_file_nc_refund_intake do
      after(:build) do |intake|
        intake.direct_file_data.fed_agi = 10000
        intake.raw_direct_file_data = intake.direct_file_data.to_s
        intake.payment_or_deposit_type = "direct_deposit"
        intake.account_type = "savings"
        intake.routing_number = 111111111
        intake.account_number = 222222222
      end
    end

    raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml('nc_daffy_single') }
    raw_direct_file_intake_data { StateFile::DirectFileApiResponseSampleService.new.read_json('nc_daffy_single') }
    df_data_import_succeeded_at { DateTime.now }
    state_file_analytics { StateFileAnalytics.create }

    primary_first_name { "North" }
    primary_middle_initial { "A" }
    primary_last_name { "Carolinian" }
    residence_county { "001" }

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
    end

    trait :with_w2s_synced do
      after(:create, &:synchronize_df_w2s_to_database)
    end

    trait :taxes_owed do
      after(:build) do |intake|
        intake.direct_file_data.fed_agi = 120000
        intake.raw_direct_file_data = intake.direct_file_data.to_s
        intake.payment_or_deposit_type = "direct_deposit"
        intake.account_type = "checking"
        intake.routing_number = 111111111
        intake.account_number = 222222222
        intake.date_electronic_withdrawal = Date.new(Rails.configuration.statefile_current_tax_year, 4, 15)
        intake.withdraw_amount = 5
      end
    end

    trait :with_spouse do
      filing_status { 'married_filing_jointly' }
      spouse_first_name { "Susie" }
      spouse_middle_initial { "B" }
      spouse_last_name { "Spouse" }
      spouse_birth_date { MultiTenantService.statefile.end_of_current_tax_year - 40 }
    end

    trait :with_senior_spouse do
      filing_status { 'married_filing_jointly' }
      spouse_first_name { "Senior" }
      spouse_middle_initial { "B" }
      spouse_last_name { "Spouse" }
      spouse_birth_date { MultiTenantService.statefile.end_of_current_tax_year - 70 }
    end

    trait :head_of_household do
      raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml('nc_nala_hoh') }
      raw_direct_file_intake_data { StateFile::DirectFileApiResponseSampleService.new.read_json('nc_nala_hoh') }
    end

    trait :married_filing_separately do
      filing_status { 'married_filing_separately' }
      raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml('nc_wylie_mfs') }
      raw_direct_file_intake_data { StateFile::DirectFileApiResponseSampleService.new.read_json('nc_wylie_mfs') }
    end

    trait :df_data_1099_int do
      raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml('nc_clara_hoh') }
      raw_direct_file_intake_data { StateFile::DirectFileApiResponseSampleService.new.read_json('nc_clara_hoh') }
    end

    trait :with_filers_synced do
      after(:create, &:synchronize_filers_to_database)
    end

    trait :mfs_with_nra_spouse do
      filing_status { 'married_filing_separately' }
      raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml('nc_wylie_mfs_nra') }
      raw_direct_file_intake_data { StateFile::DirectFileApiResponseSampleService.new.read_json('nc_wylie_mfs_nra') }

      after(:create, &:synchronize_filers_to_database)
    end
  end
end
