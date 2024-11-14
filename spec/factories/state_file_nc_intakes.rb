# == Schema Information
#
# Table name: state_file_nc_intakes
#
#  id                                :bigint           not null, primary key
#  account_number                    :string
#  account_type                      :integer          default("unfilled"), not null
#  bank_name                         :string
#  city                              :string
#  consented_to_terms_and_conditions :integer          default("unfilled"), not null
#  contact_preference                :integer          default("unfilled"), not null
#  current_sign_in_at                :datetime
#  current_sign_in_ip                :inet
#  current_step                      :string
#  date_electronic_withdrawal        :date
#  df_data_import_failed_at          :datetime
#  df_data_imported_at               :datetime
#  eligibility_lived_in_state        :integer          default("unfilled"), not null
#  eligibility_out_of_state_income   :integer          default("unfilled"), not null
#  eligibility_withdrew_529          :integer          default("unfilled"), not null
#  email_address                     :citext
#  email_address_verified_at         :datetime
#  failed_attempts                   :integer          default(0), not null
#  federal_return_status             :string
#  hashed_ssn                        :string
#  last_sign_in_at                   :datetime
#  last_sign_in_ip                   :inet
#  locale                            :string           default("en")
#  locked_at                         :datetime
#  message_tracker                   :jsonb
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
#  routing_number                    :integer
#  sales_use_tax                     :decimal(12, 2)
#  sales_use_tax_calculation_method  :integer          default("unfilled"), not null
#  sign_in_count                     :integer          default(0), not null
#  source                            :string
#  spouse_birth_date                 :date
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
      filing_status { 'married_filing_jointly' }
    end

    raw_direct_file_data { File.read(Rails.root.join('spec', 'fixtures', 'state_file', 'fed_return_xmls', '2023', 'nc', 'nick.xml')) }
    raw_direct_file_intake_data { StateFile::DirectFileApiResponseSampleService.new.read_json('nc_nick') }
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

    trait :df_data_2_w2s do
      raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml('nc_spiderman') }
    end

    trait :df_data_many_w2s do
      raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml('nc_cookiemonster') }
    end

    trait :single do
      raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml('nc_tucker_single') }
    end

    trait :head_of_household do
      raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml('nc_shiloh_hoh') }
    end

    trait :married_filing_separately do
      raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml('nc_sheldon_mfs') }
    end

    trait :qualified_widow do
      raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml('nc_laney_qss') }
    end

    trait :df_data_1099_int do
      raw_direct_file_data { StateFile::DirectFileApiResponseSampleService.new.read_xml('nc_tom_1099_int') }
      raw_direct_file_intake_data { StateFile::DirectFileApiResponseSampleService.new.read_json('nc_tom_1099_int') }
    end

    trait :with_filers_synced do
      after(:create, &:synchronize_filers_to_database)
    end
  end
end
