# == Schema Information
#
# Table name: state_file_nj_intakes
#
#  id                                :bigint           not null, primary key
#  account_number                    :string
#  account_type                      :integer          default("unfilled"), not null
#  bank_name                         :string
#  claimed_as_dep                    :integer
#  consented_to_terms_and_conditions :integer          default("unfilled"), not null
#  contact_preference                :integer          default("unfilled"), not null
#  county                            :string
#  current_sign_in_at                :datetime
#  current_sign_in_ip                :inet
#  current_step                      :string
#  date_electronic_withdrawal        :date
#  df_data_import_failed_at          :datetime
#  df_data_imported_at               :datetime
#  eligibility_lived_in_state        :integer          default("unfilled"), not null
#  eligibility_out_of_state_income   :integer          default("unfilled"), not null
#  email_address                     :citext
#  email_address_verified_at         :datetime
#  failed_attempts                   :integer          default(0), not null
#  fed_taxable_income                :integer
#  fed_wages                         :integer
#  federal_return_status             :string
#  hashed_ssn                        :string
#  last_sign_in_at                   :datetime
#  last_sign_in_ip                   :inet
#  locale                            :string           default("en")
#  locked_at                         :datetime
#  message_tracker                   :jsonb
#  municipality_code                 :string
#  municipality_name                 :string
#  payment_or_deposit_type           :integer          default("unfilled"), not null
#  permanent_apartment               :string
#  permanent_city                    :string
#  permanent_street                  :string
#  permanent_zip                     :string
#  phone_number                      :string
#  phone_number_verified_at          :datetime
#  primary_birth_date                :date
#  primary_esigned                   :integer          default("unfilled"), not null
#  primary_esigned_at                :datetime
#  primary_first_name                :string
#  primary_last_name                 :string
#  primary_middle_initial            :string
#  primary_signature                 :string
#  primary_ssn                       :string
#  primary_suffix                    :string
#  raw_direct_file_data              :text
#  referrer                          :string
#  routing_number                    :string
#  sign_in_count                     :integer          default(0), not null
#  source                            :string
#  spouse_birth_date                 :date
#  spouse_esigned                    :integer          default("unfilled"), not null
#  spouse_esigned_at                 :datetime
#  spouse_first_name                 :string
#  spouse_last_name                  :string
#  spouse_middle_initial             :string
#  spouse_ssn                        :string
#  spouse_suffix                     :string
#  tax_return_year                   :integer
#  unfinished_intake_ids             :text             default([]), is an Array
#  unsubscribed_from_email           :boolean          default(FALSE), not null
#  withdraw_amount                   :integer
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  federal_submission_id             :string
#  primary_state_id_id               :bigint
#  spouse_state_id_id                :bigint
#  visitor_id                        :string
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

    raw_direct_file_data { File.read(Rails.root.join('spec', 'fixtures', 'state_file', 'fed_return_xmls', '2023', 'nj', 'zeus_one_dep.xml')) }
    primary_first_name { "New" }
    primary_last_name { "Jerseyan" }
    primary_birth_date { Date.new(1990, 1, 1) }

    after(:build) do |intake, evaluator|
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

    after(:create) do |intake|
      intake.synchronize_df_dependents_to_database
      intake.dependents.each_with_index do |dependent, i|
        dependent.update( dob: i.years.ago )
      end
    end

    trait :df_data_2_w2s do
      raw_direct_file_data { StateFile::XmlReturnSampleService.new.read('nj_zeus_two_w2s') }
    end

    trait :df_data_many_w2s do
      raw_direct_file_data { StateFile::XmlReturnSampleService.new.read('nj_zeus_many_w2s') }
    end

    trait :df_data_minimal do
      raw_direct_file_data { StateFile::XmlReturnSampleService.new.read('nj_minimal') }
    end

    trait :df_data_many_deps do
      raw_direct_file_data { StateFile::XmlReturnSampleService.new.read('nj_zeus_many_deps') }
    end

    trait :df_data_one_dep do
      raw_direct_file_data { StateFile::XmlReturnSampleService.new.read('nj_zeus_one_dep') }
    end

    trait :married_filing_jointly do
      filing_status { "married_filing_jointly" }
      spouse_birth_date { Date.new(1990, 1, 1) }
      spouse_ssn { "123456789" }
    end

    trait :primary_over_65 do
      primary_birth_date { Date.new(1900, 1, 1) }
    end

    trait :mfj_spouse_over_65 do
      filing_status { "married_filing_jointly" }
      spouse_birth_date { Date.new(1900, 1, 1) }
      spouse_ssn { "123456789" }
    end
  end
end
