# == Schema Information
#
# Table name: state_file_az_intakes
#
#  id                                    :bigint           not null, primary key
#  account_number                        :string
#  account_type                          :integer
#  armed_forces_member                   :integer          default("unfilled"), not null
#  armed_forces_wages                    :integer
#  bank_name                             :string
#  charitable_cash                       :integer          default(0)
#  charitable_contributions              :integer          default("unfilled"), not null
#  charitable_noncash                    :integer          default(0)
#  consented_to_terms_and_conditions     :integer          default("unfilled"), not null
#  contact_preference                    :integer          default("unfilled"), not null
#  current_sign_in_at                    :datetime
#  current_sign_in_ip                    :inet
#  current_step                          :string
#  date_electronic_withdrawal            :date
#  eligibility_529_for_non_qual_expense  :integer          default("unfilled"), not null
#  eligibility_lived_in_state            :integer          default("unfilled"), not null
#  eligibility_married_filing_separately :integer          default("unfilled"), not null
#  eligibility_out_of_state_income       :integer          default("unfilled"), not null
#  email_address                         :citext
#  email_address_verified_at             :datetime
#  failed_attempts                       :integer          default(0), not null
#  federal_return_status                 :string
#  has_prior_last_names                  :integer          default("unfilled"), not null
#  hashed_ssn                            :string
#  last_sign_in_at                       :datetime
#  last_sign_in_ip                       :inet
#  locked_at                             :datetime
#  payment_or_deposit_type               :integer          default("unfilled"), not null
#  phone_number                          :string
#  phone_number_verified_at              :datetime
#  primary_esigned                       :integer          default("unfilled"), not null
#  primary_esigned_at                    :datetime
#  primary_first_name                    :string
#  primary_last_name                     :string
#  primary_middle_initial                :string
#  prior_last_names                      :string
#  raw_direct_file_data                  :text
#  referrer                              :string
#  routing_number                        :string
#  sign_in_count                         :integer          default(0), not null
#  source                                :string
#  spouse_esigned                        :integer          default("unfilled"), not null
#  spouse_esigned_at                     :datetime
#  spouse_first_name                     :string
#  spouse_last_name                      :string
#  spouse_middle_initial                 :string
#  tribal_member                         :integer          default("unfilled"), not null
#  tribal_wages                          :integer
#  was_incarcerated                      :integer          default("unfilled"), not null
#  withdraw_amount                       :integer
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#  federal_submission_id                 :string
#  primary_state_id_id                   :bigint
#  spouse_state_id_id                    :bigint
#  visitor_id                            :string
#
# Indexes
#
#  index_state_file_az_intakes_on_hashed_ssn           (hashed_ssn)
#  index_state_file_az_intakes_on_primary_state_id_id  (primary_state_id_id)
#  index_state_file_az_intakes_on_spouse_state_id_id   (spouse_state_id_id)
#
FactoryBot.define do
  factory :minimal_state_file_az_intake, class: "StateFileAzIntake"

  factory :state_file_az_intake do
    transient do
      filing_status { 'single' }
    end

    raw_direct_file_data { File.read(Rails.root.join('app', 'controllers', 'state_file', 'questions', 'df_return_sample.xml')) }
    primary_first_name { "Ariz" }
    primary_last_name { "Onian" }

    after(:build) do |intake, evaluator|
      numeric_status = {
        single: 1,
        married_filing_jointly: 2,
        married_filing_separately: 3,
        head_of_household: 4,
        qualifying_widow: 5,
      }[evaluator.filing_status.to_sym] || evaluator.filing_status
      intake.direct_file_data.filing_status = numeric_status
      intake.direct_file_data.fed_agi = 120000
      intake.direct_file_data.fed_w2_state = "AZ"
      intake.raw_direct_file_data = intake.direct_file_data.to_s
    end

    factory :state_file_az_refund_intake do
      after(:build) do |intake, evaluator|
        intake.direct_file_data.fed_agi = 10000
        intake.raw_direct_file_data = intake.direct_file_data.to_s
      end
    end

    factory :state_file_az_owed_intake do
      after(:build) do |intake, evaluator|
        intake.direct_file_data.fed_agi = 120000
        intake.raw_direct_file_data = intake.direct_file_data.to_s
      end
    end

    trait :with_efile_device_infos do
      after(:build) do |intake|
        create :state_file_efile_device_info, :filled, :initial_creation, intake: intake
        create :state_file_efile_device_info, :filled, :submission, intake: intake
      end
    end

    factory :state_file_az_intake_after_transfer do
      sequence(:hashed_ssn) { |n| "abcdefg12346#{n}" }
    end
  end
end
