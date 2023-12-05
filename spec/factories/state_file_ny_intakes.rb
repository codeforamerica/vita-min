# == Schema Information
#
# Table name: state_file_ny_intakes
#
#  id                                 :bigint           not null, primary key
#  account_number                     :string
#  account_type                       :integer          default("unfilled"), not null
#  bank_name                          :string
#  confirmed_permanent_address        :integer          default("unfilled"), not null
#  contact_preference                 :integer          default("unfilled"), not null
#  current_sign_in_at                 :datetime
#  current_sign_in_ip                 :inet
#  current_step                       :string
#  date_electronic_withdrawal         :date
#  eligibility_lived_in_state         :integer          default("unfilled"), not null
#  eligibility_out_of_state_income    :integer          default("unfilled"), not null
#  eligibility_part_year_nyc_resident :integer          default("unfilled"), not null
#  eligibility_withdrew_529           :integer          default("unfilled"), not null
#  eligibility_yonkers                :integer          default("unfilled"), not null
#  email_address                      :citext
#  email_address_verified_at          :datetime
#  failed_attempts                    :integer          default(0), not null
#  household_cash_assistance          :integer
#  household_fed_agi                  :integer
#  household_ny_additions             :integer
#  household_other_income             :integer
#  household_own_assessments          :integer
#  household_own_propety_tax          :integer
#  household_rent_adjustments         :integer
#  household_rent_amount              :integer
#  household_rent_own                 :integer          default("unfilled"), not null
#  household_ssi                      :integer
#  last_sign_in_at                    :datetime
#  last_sign_in_ip                    :inet
#  locked_at                          :datetime
#  mailing_country                    :string
#  mailing_state                      :string
#  nursing_home                       :integer          default("unfilled"), not null
#  ny_mailing_apartment               :string
#  ny_mailing_city                    :string
#  ny_mailing_street                  :string
#  ny_mailing_zip                     :string
#  nyc_full_year_resident             :integer          default("unfilled"), not null
#  occupied_residence                 :integer          default("unfilled"), not null
#  payment_or_deposit_type            :integer          default("unfilled"), not null
#  permanent_apartment                :string
#  permanent_city                     :string
#  permanent_street                   :string
#  permanent_zip                      :string
#  phone_number                       :string
#  phone_number_verified_at           :datetime
#  primary_birth_date                 :date
#  primary_email                      :string
#  primary_esigned                    :integer          default("unfilled"), not null
#  primary_esigned_at                 :datetime
#  primary_first_name                 :string
#  primary_last_name                  :string
#  primary_middle_initial             :string
#  primary_signature                  :string
#  property_over_limit                :integer          default("unfilled"), not null
#  public_housing                     :integer          default("unfilled"), not null
#  raw_direct_file_data               :text
#  referrer                           :string
#  residence_county                   :string
#  routing_number                     :string
#  sales_use_tax                      :integer
#  sales_use_tax_calculation_method   :integer          default("unfilled"), not null
#  school_district                    :string
#  school_district_number             :integer
#  sign_in_count                      :integer          default(0), not null
#  source                             :string
#  spouse_birth_date                  :date
#  spouse_esigned                     :integer          default("unfilled"), not null
#  spouse_esigned_at                  :datetime
#  spouse_first_name                  :string
#  spouse_last_name                   :string
#  spouse_middle_initial              :string
#  spouse_signature                   :string
#  untaxed_out_of_state_purchases     :integer          default("unfilled"), not null
#  withdraw_amount                    :integer
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  primary_state_id_id                :bigint
#  spouse_state_id_id                 :bigint
#  visitor_id                         :string
#
# Indexes
#
#  index_state_file_ny_intakes_on_primary_state_id_id  (primary_state_id_id)
#  index_state_file_ny_intakes_on_spouse_state_id_id   (spouse_state_id_id)
#
FactoryBot.define do
  factory :state_file_ny_intake do
    transient do
      filing_status { 'single' }
    end

    raw_direct_file_data { File.read(Rails.root.join('app', 'controllers', 'state_file', 'questions', 'df_return_sample.xml')) }
    primary_first_name { "New" }
    primary_last_name { "Yorker" }
    primary_birth_date{ Date.parse("May 1, 1979") }
    permanent_street { direct_file_data.mailing_street }
    permanent_city { direct_file_data.mailing_city }
    permanent_zip { direct_file_data.mailing_zip }
    nyc_full_year_resident { 'yes' }
    school_district { "Cool School" }
    school_district_number { 123 }

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

    trait :mfj_with_complete_spouse do
      transient do
        filing_status { 'married_filing_jointly' }
        spouse_ssn { "123456789" }
        spouse_occupation { "123456789" }
      end

      spouse_birth_date { Date.new(1990, 1, 1) }
      spouse_first_name { "Spousel" }
      spouse_last_name { "Testerson" }
      spouse_middle_initial { "T" }

      after(:build) do |intake, evaluator|
        intake.direct_file_data.spouse_ssn = evaluator.spouse_ssn
        intake.direct_file_data.spouse_occupation = evaluator.spouse_occupation
        intake.raw_direct_file_data = intake.direct_file_data.to_s
      end
    end

    factory :state_file_ny_owed_intake do
      nyc_full_year_resident { 'no' }
      after(:build) do |intake, evaluator|
        intake.direct_file_data.fed_unemployment = 45000
        intake.raw_direct_file_data = intake.direct_file_data.to_s
      end
    end

    factory :state_file_ny_refund_intake do
      after(:build) do |intake, evaluator|
        intake.direct_file_data.fed_wages = 2_000
        intake.direct_file_data.fed_taxable_income = 2_000
        intake.direct_file_data.fed_taxable_ssb = 0
        intake.direct_file_data.fed_unemployment = 0
        intake.raw_direct_file_data = intake.direct_file_data.to_s
      end
    end

    trait :with_efile_device_infos do
      after(:build) do |intake|
        create :state_file_efile_device_info, :filled, :initial_creation, intake: intake
        create :state_file_efile_device_info, :filled, :submission, intake: intake
      end
    end
  end
end
