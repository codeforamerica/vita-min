# == Schema Information
#
# Table name: intakes
#
#  id                                                   :bigint           not null, primary key
#  additional_info                                      :string
#  adopted_child                                        :integer          default("unfilled"), not null
#  already_applied_for_stimulus                         :integer          default("unfilled"), not null
#  already_filed                                        :integer          default("unfilled"), not null
#  anonymous                                            :boolean          default(FALSE), not null
#  balance_pay_from_bank                                :integer          default("unfilled"), not null
#  bank_account_type                                    :integer          default("unfilled"), not null
#  bought_energy_efficient_items                        :integer
#  bought_health_insurance                              :integer          default("unfilled"), not null
#  city                                                 :string
#  claimed_by_another                                   :integer          default("unfilled"), not null
#  completed_at                                         :datetime
#  completed_intake_sent_to_zendesk                     :boolean
#  continued_at_capacity                                :boolean          default(FALSE)
#  demographic_disability                               :integer          default("unfilled"), not null
#  demographic_english_conversation                     :integer          default("unfilled"), not null
#  demographic_english_reading                          :integer          default("unfilled"), not null
#  demographic_primary_american_indian_alaska_native    :boolean
#  demographic_primary_asian                            :boolean
#  demographic_primary_black_african_american           :boolean
#  demographic_primary_ethnicity                        :integer          default("unfilled"), not null
#  demographic_primary_native_hawaiian_pacific_islander :boolean
#  demographic_primary_prefer_not_to_answer_race        :boolean
#  demographic_primary_white                            :boolean
#  demographic_questions_opt_in                         :integer          default("unfilled"), not null
#  demographic_spouse_american_indian_alaska_native     :boolean
#  demographic_spouse_asian                             :boolean
#  demographic_spouse_black_african_american            :boolean
#  demographic_spouse_ethnicity                         :integer          default("unfilled"), not null
#  demographic_spouse_native_hawaiian_pacific_islander  :boolean
#  demographic_spouse_prefer_not_to_answer_race         :boolean
#  demographic_spouse_white                             :boolean
#  demographic_veteran                                  :integer          default("unfilled"), not null
#  divorced                                             :integer          default("unfilled"), not null
#  divorced_year                                        :string
#  eip_only                                             :boolean
#  email_address                                        :string
#  email_notification_opt_in                            :integer          default("unfilled"), not null
#  encrypted_bank_account_number                        :string
#  encrypted_bank_account_number_iv                     :string
#  encrypted_bank_name                                  :string
#  encrypted_bank_name_iv                               :string
#  encrypted_bank_routing_number                        :string
#  encrypted_bank_routing_number_iv                     :string
#  encrypted_primary_last_four_ssn                      :string
#  encrypted_primary_last_four_ssn_iv                   :string
#  encrypted_spouse_last_four_ssn                       :string
#  encrypted_spouse_last_four_ssn_iv                    :string
#  ever_married                                         :integer          default("unfilled"), not null
#  feedback                                             :string
#  feeling_about_taxes                                  :integer          default("unfilled"), not null
#  filing_for_stimulus                                  :integer          default("unfilled"), not null
#  filing_joint                                         :integer          default("unfilled"), not null
#  final_info                                           :string
#  had_asset_sale_income                                :integer          default("unfilled"), not null
#  had_debt_forgiven                                    :integer          default("unfilled"), not null
#  had_dependents                                       :integer          default("unfilled"), not null
#  had_disability                                       :integer          default("unfilled"), not null
#  had_disability_income                                :integer          default("unfilled"), not null
#  had_disaster_loss                                    :integer          default("unfilled"), not null
#  had_farm_income                                      :integer          default("unfilled"), not null
#  had_gambling_income                                  :integer          default("unfilled"), not null
#  had_hsa                                              :integer          default("unfilled"), not null
#  had_interest_income                                  :integer          default("unfilled"), not null
#  had_local_tax_refund                                 :integer          default("unfilled"), not null
#  had_other_income                                     :integer          default("unfilled"), not null
#  had_rental_income                                    :integer          default("unfilled"), not null
#  had_retirement_income                                :integer          default("unfilled"), not null
#  had_self_employment_income                           :integer          default("unfilled"), not null
#  had_social_security_income                           :integer          default("unfilled"), not null
#  had_social_security_or_retirement                    :integer          default("unfilled"), not null
#  had_student_in_family                                :integer          default("unfilled"), not null
#  had_tax_credit_disallowed                            :integer          default("unfilled"), not null
#  had_tips                                             :integer          default("unfilled"), not null
#  had_unemployment_income                              :integer          default("unfilled"), not null
#  had_wages                                            :integer          default("unfilled"), not null
#  has_enqueued_ticket_creation                         :boolean          default(FALSE)
#  income_over_limit                                    :integer          default("unfilled"), not null
#  intake_pdf_sent_to_zendesk                           :boolean          default(FALSE), not null
#  interview_timing_preference                          :string
#  issued_identity_pin                                  :integer          default("unfilled"), not null
#  job_count                                            :integer
#  lived_with_spouse                                    :integer          default("unfilled"), not null
#  locale                                               :string
#  made_estimated_tax_payments                          :integer          default("unfilled"), not null
#  married                                              :integer          default("unfilled"), not null
#  multiple_states                                      :integer          default("unfilled"), not null
#  needs_help_2016                                      :integer          default("unfilled"), not null
#  needs_help_2017                                      :integer          default("unfilled"), not null
#  needs_help_2018                                      :integer          default("unfilled"), not null
#  needs_help_2019                                      :integer          default("unfilled"), not null
#  needs_help_2020                                      :integer          default("unfilled"), not null
#  no_eligibility_checks_apply                          :integer          default("unfilled"), not null
#  no_ssn                                               :integer          default("unfilled"), not null
#  other_income_types                                   :string
#  paid_alimony                                         :integer          default("unfilled"), not null
#  paid_charitable_contributions                        :integer          default("unfilled"), not null
#  paid_dependent_care                                  :integer          default("unfilled"), not null
#  paid_local_tax                                       :integer          default("unfilled"), not null
#  paid_medical_expenses                                :integer          default("unfilled"), not null
#  paid_mortgage_interest                               :integer          default("unfilled"), not null
#  paid_retirement_contributions                        :integer          default("unfilled"), not null
#  paid_school_supplies                                 :integer          default("unfilled"), not null
#  paid_student_loan_interest                           :integer          default("unfilled"), not null
#  phone_number                                         :string
#  phone_number_can_receive_texts                       :integer          default("unfilled"), not null
#  preferred_interview_language                         :string
#  preferred_name                                       :string
#  primary_birth_date                                   :date
#  primary_consented_to_service                         :integer          default("unfilled"), not null
#  primary_consented_to_service_at                      :datetime
#  primary_consented_to_service_ip                      :inet
#  primary_first_name                                   :string
#  primary_last_name                                    :string
#  received_alimony                                     :integer          default("unfilled"), not null
#  received_homebuyer_credit                            :integer          default("unfilled"), not null
#  received_irs_letter                                  :integer          default("unfilled"), not null
#  referrer                                             :string
#  refund_payment_method                                :integer          default("unfilled"), not null
#  reported_asset_sale_loss                             :integer          default("unfilled"), not null
#  reported_self_employment_loss                        :integer          default("unfilled"), not null
#  requested_docs_token                                 :string
#  requested_docs_token_created_at                      :datetime
#  routed_at                                            :datetime
#  routing_criteria                                     :string
#  routing_value                                        :string
#  satisfaction_face                                    :integer          default("unfilled"), not null
#  savings_purchase_bond                                :integer          default("unfilled"), not null
#  savings_split_refund                                 :integer          default("unfilled"), not null
#  separated                                            :integer          default("unfilled"), not null
#  separated_year                                       :string
#  signature_method                                     :integer          default("online"), not null
#  sms_notification_opt_in                              :integer          default("unfilled"), not null
#  sms_phone_number                                     :string
#  sold_a_home                                          :integer          default("unfilled"), not null
#  sold_assets                                          :integer          default("unfilled"), not null
#  source                                               :string
#  spouse_auth_token                                    :string
#  spouse_birth_date                                    :date
#  spouse_consented_to_service                          :integer          default("unfilled"), not null
#  spouse_consented_to_service_at                       :datetime
#  spouse_consented_to_service_ip                       :inet
#  spouse_email_address                                 :string
#  spouse_first_name                                    :string
#  spouse_had_disability                                :integer          default("unfilled"), not null
#  spouse_issued_identity_pin                           :integer          default("unfilled"), not null
#  spouse_last_name                                     :string
#  spouse_was_blind                                     :integer          default("unfilled"), not null
#  spouse_was_full_time_student                         :integer          default("unfilled"), not null
#  spouse_was_on_visa                                   :integer          default("unfilled"), not null
#  state                                                :string
#  state_of_residence                                   :string
#  street_address                                       :string
#  timezone                                             :string
#  triage_source_type                                   :string
#  viewed_at_capacity                                   :boolean          default(FALSE)
#  vita_partner_name                                    :string
#  was_blind                                            :integer          default("unfilled"), not null
#  was_full_time_student                                :integer          default("unfilled"), not null
#  was_on_visa                                          :integer          default("unfilled"), not null
#  widowed                                              :integer          default("unfilled"), not null
#  widowed_year                                         :string
#  zendesk_instance_domain                              :string
#  zip_code                                             :string
#  created_at                                           :datetime
#  updated_at                                           :datetime
#  client_id                                            :bigint
#  intake_ticket_id                                     :bigint
#  intake_ticket_requester_id                           :bigint
#  primary_intake_id                                    :integer
#  triage_source_id                                     :bigint
#  visitor_id                                           :string
#  vita_partner_group_id                                :string
#  vita_partner_id                                      :bigint
#
# Indexes
#
#  index_intakes_on_client_id                                (client_id)
#  index_intakes_on_email_address                            (email_address)
#  index_intakes_on_intake_ticket_id                         (intake_ticket_id)
#  index_intakes_on_phone_number                             (phone_number)
#  index_intakes_on_sms_phone_number                         (sms_phone_number)
#  index_intakes_on_triage_source_type_and_triage_source_id  (triage_source_type,triage_source_id)
#  index_intakes_on_vita_partner_id                          (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#

FactoryBot.define do
  factory :intake do
    had_wages { :unfilled }
    client

    factory :anonymous_intake do
      anonymous { true }
    end

    trait :with_ticket do
      intake_ticket_id { 123 }
    end

    trait :eip_only do
      eip_only { true }
    end

    trait :with_banking_details do
      bank_name { "Self-help United" }
      bank_routing_number { "12345678" }
      bank_account_number { "87654321" }
      bank_account_type { "checking" }
    end

    trait :with_dependents do
      transient do
        dependent_count { 1 }
      end

      after(:build) do |intake, evaluator|
        create_list(:dependent, evaluator.dependent_count, intake: intake)
      end
    end

    trait :with_documents do
      transient do
        document_count { 1 }
      end

      after(:build) do |intake, evaluator|
        create_list(:document, evaluator.dependent_count, intake: intake)
      end
    end

    trait :with_contact_info do
      preferred_name { "Cherry" }
      primary_first_name { "Cher" }
      primary_last_name { "Cherimoya" }
      phone_number { "+14155551212" }
      sms_phone_number { "+14155551212" }
      email_address { "cher@example.com" }
      email_notification_opt_in { "yes" }
    end

    trait :filled_out do
      document_count  { [1, 2, 3].sample }
      dependent_count { [1, 2, 3].sample }
      with_dependents
      intake_ticket_id { 192 }
      with_documents
      vita_partner
      locale { ["en", "es"].sample }
      source { vita_partner.source_parameters.first || "none" }
      referrer { "/" }
      primary_birth_date { (20..100).to_a.sample.years.ago }
      spouse_birth_date { (20..100).to_a.sample.years.ago }
      zip_code { ZipCodes::ZIP_CODES.keys.sample }
      city { ZipCodes::ZIP_CODES[zip_code][:name].split(", ").first }
      state { ZipCodes::ZIP_CODES[zip_code][:name].split(", ").last }
      state_of_residence { state }
      zendesk_instance_domain { "eitc" }
      vita_partner_group_id { vita_partner.zendesk_group_id }
      vita_partner_name { vita_partner.name }
      routing_value { vita_partner.states.first&.abbreviation || "az" }
      routing_criteria { "state" }
      job_count { [1, 2, 3].sample }
      preferred_interview_language { ["en", "es"].sample }
      primary_consented_to_service_at { 2.weeks.ago }
      completed_at { 1.week.ago }
      demographic_primary_american_indian_alaska_native { true }
      demographic_primary_black_african_american { true }
      demographic_primary_native_hawaiian_pacific_islander { true }
      demographic_primary_asian { true }
      demographic_primary_white { true }
      demographic_primary_prefer_not_to_answer_race { true }
      after(:build) do |intake|
        Intake.defined_enums.each_key do |key|
          # only randomize values for keys that have not been supplied
          unless intake[key] == "unfilled"
            intake[key] = Intake.send(key.pluralize).keys.sample
          end
        end
      end
    end
  end
end
