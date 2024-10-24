# == Schema Information
#
# Table name: state_file_id_intakes
#
#  id                                      :bigint           not null, primary key
#  account_number                          :string
#  account_type                            :integer          default("unfilled"), not null
#  bank_name                               :string
#  consented_to_terms_and_conditions       :integer          default("unfilled"), not null
#  contact_preference                      :integer          default("unfilled"), not null
#  current_sign_in_at                      :datetime
#  current_sign_in_ip                      :inet
#  current_step                            :string
#  date_electronic_withdrawal              :date
#  df_data_import_failed_at                :datetime
#  df_data_imported_at                     :datetime
#  eligibility_emergency_rental_assistance :integer          default("unfilled"), not null
#  eligibility_withdrew_msa_fthb           :integer          default("unfilled"), not null
#  email_address                           :citext
#  email_address_verified_at               :datetime
#  failed_attempts                         :integer          default(0), not null
#  federal_return_status                   :string
#  has_unpaid_sales_use_tax                :integer          default("unfilled"), not null
#  hashed_ssn                              :string
#  last_sign_in_at                         :datetime
#  last_sign_in_ip                         :inet
#  locale                                  :string           default("en")
#  locked_at                               :datetime
#  message_tracker                         :jsonb
#  payment_or_deposit_type                 :integer          default("unfilled"), not null
#  phone_number                            :string
#  phone_number_verified_at                :datetime
#  primary_birth_date                      :date
#  primary_esigned                         :integer          default("unfilled"), not null
#  primary_esigned_at                      :datetime
#  primary_first_name                      :string
#  primary_last_name                       :string
#  primary_middle_initial                  :string
#  primary_suffix                          :string
#  raw_direct_file_data                    :text
#  raw_direct_file_intake_data             :jsonb
#  referrer                                :string
#  routing_number                          :integer
#  sign_in_count                           :integer          default(0), not null
#  source                                  :string
#  spouse_birth_date                       :date
#  spouse_esigned                          :integer          default("unfilled"), not null
#  spouse_esigned_at                       :datetime
#  spouse_first_name                       :string
#  spouse_last_name                        :string
#  spouse_middle_initial                   :string
#  spouse_suffix                           :string
#  total_purchase_amount                   :decimal(12, 2)
#  unsubscribed_from_email                 :boolean          default(FALSE), not null
#  withdraw_amount                         :integer
#  created_at                              :datetime         not null
#  updated_at                              :datetime         not null
#  federal_submission_id                   :string
#  visitor_id                              :string
#
# Indexes
#
#  index_state_file_id_intakes_on_email_address  (email_address)
#  index_state_file_id_intakes_on_hashed_ssn     (hashed_ssn)
#
FactoryBot.define do
  factory :minimal_state_file_id_intake, class: "StateFileIdIntake"
  factory :state_file_id_intake do
    raw_direct_file_data { File.read(Rails.root.join('app', 'controllers', 'state_file', 'questions', 'df_return_sample.xml')) }

    transient do
      filing_status { "single" }
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
    end
  end
end
