# == Schema Information
#
# Table name: intakes
#
#  id                                                   :bigint           not null, primary key
#  additional_info                                      :string
#  adopted_child                                        :integer          default("unfilled"), not null
#  advance_ctc_amount_received                          :integer
#  advance_ctc_entry_method                             :integer          default(0), not null
#  already_applied_for_stimulus                         :integer          default("unfilled"), not null
#  already_filed                                        :integer          default("unfilled"), not null
#  balance_pay_from_bank                                :integer          default("unfilled"), not null
#  bank_account_number                                  :text
#  bank_account_type                                    :integer          default("unfilled"), not null
#  bank_name                                            :string
#  bank_routing_number                                  :string
#  bought_employer_health_insurance                     :integer          default("unfilled"), not null
#  bought_energy_efficient_items                        :integer
#  bought_marketplace_health_insurance                  :integer          default("unfilled"), not null
#  cannot_claim_me_as_a_dependent                       :integer          default(0), not null
#  canonical_email_address                              :string
#  city                                                 :string
#  claim_eitc                                           :integer          default(0), not null
#  claim_owed_stimulus_money                            :integer          default("unfilled"), not null
#  claimed_by_another                                   :integer          default("unfilled"), not null
#  completed_at                                         :datetime
#  completed_yes_no_questions_at                        :datetime
#  consented_to_legal                                   :integer          default(0), not null
#  continued_at_capacity                                :boolean          default(FALSE)
#  contributed_to_401k                                  :integer          default("unfilled"), not null
#  contributed_to_ira                                   :integer          default("unfilled"), not null
#  contributed_to_other_retirement_account              :integer          default("unfilled"), not null
#  contributed_to_roth_ira                              :integer          default("unfilled"), not null
#  current_step                                         :string
#  demographic_disability                               :integer          default("unfilled"), not null
#  demographic_english_conversation                     :integer          default("unfilled"), not null
#  demographic_english_reading                          :integer          default("unfilled"), not null
#  demographic_primary_american_indian_alaska_native    :boolean
#  demographic_primary_asian                            :boolean
#  demographic_primary_black_african_american           :boolean
#  demographic_primary_ethnicity                        :integer          default("unfilled"), not null
#  demographic_primary_hispanic_latino                  :boolean
#  demographic_primary_mena                             :boolean
#  demographic_primary_native_hawaiian_pacific_islander :boolean
#  demographic_primary_prefer_not_to_answer_race        :boolean
#  demographic_primary_white                            :boolean
#  demographic_questions_hub_edit                       :boolean          default(FALSE)
#  demographic_questions_opt_in                         :integer          default("unfilled"), not null
#  demographic_spouse_american_indian_alaska_native     :boolean
#  demographic_spouse_asian                             :boolean
#  demographic_spouse_black_african_american            :boolean
#  demographic_spouse_ethnicity                         :integer          default("unfilled"), not null
#  demographic_spouse_hispanic_latino                   :boolean
#  demographic_spouse_mena                              :boolean
#  demographic_spouse_native_hawaiian_pacific_islander  :boolean
#  demographic_spouse_prefer_not_to_answer_race         :boolean
#  demographic_spouse_white                             :boolean
#  demographic_veteran                                  :integer          default("unfilled"), not null
#  disallowed_ctc                                       :boolean
#  divorced                                             :integer          default("unfilled"), not null
#  divorced_year                                        :string
#  eip1_amount_received                                 :integer
#  eip1_and_2_amount_received_confidence                :integer
#  eip1_entry_method                                    :integer          default(0), not null
#  eip2_amount_received                                 :integer
#  eip2_entry_method                                    :integer          default(0), not null
#  eip3_amount_received                                 :integer
#  eip3_entry_method                                    :integer          default(0), not null
#  eip_only                                             :boolean
#  email_address                                        :citext
#  email_address_verified_at                            :datetime
#  email_domain                                         :string
#  email_notification_opt_in                            :integer          default("unfilled"), not null
#  ever_married                                         :integer          default("unfilled"), not null
#  ever_owned_home                                      :integer          default("unfilled"), not null
#  exceeded_investment_income_limit                     :integer          default(0)
#  feedback                                             :string
#  feeling_about_taxes                                  :integer          default("unfilled"), not null
#  filed_2020                                           :integer          default(0), not null
#  filed_prior_tax_year                                 :integer          default(0), not null
#  filing_for_stimulus                                  :integer          default("unfilled"), not null
#  filing_joint                                         :integer          default("unfilled"), not null
#  final_info                                           :string
#  former_foster_youth                                  :integer          default(0), not null
#  full_time_student_less_than_five_months              :integer          default(0), not null
#  got_married_during_tax_year                          :integer          default("unfilled"), not null
#  had_asset_sale_income                                :integer          default("unfilled"), not null
#  had_capital_loss_carryover                           :integer          default("unfilled"), not null
#  had_cash_check_digital_assets                        :integer          default("unfilled"), not null
#  had_debt_forgiven                                    :integer          default("unfilled"), not null
#  had_dependents                                       :integer          default("unfilled"), not null
#  had_disability                                       :integer          default("unfilled"), not null
#  had_disability_income                                :integer          default("unfilled"), not null
#  had_disaster_loss                                    :integer          default("unfilled"), not null
#  had_disaster_loss_where                              :string
#  had_disqualifying_non_w2_income                      :integer
#  had_farm_income                                      :integer          default("unfilled"), not null
#  had_gambling_income                                  :integer          default("unfilled"), not null
#  had_hsa                                              :integer          default("unfilled"), not null
#  had_interest_income                                  :integer          default("unfilled"), not null
#  had_local_tax_refund                                 :integer          default("unfilled"), not null
#  had_medicaid_medicare                                :integer          default("unfilled"), not null
#  had_other_income                                     :integer          default("unfilled"), not null
#  had_rental_income                                    :integer          default("unfilled"), not null
#  had_retirement_income                                :integer          default("unfilled"), not null
#  had_scholarships                                     :integer          default("unfilled"), not null
#  had_self_employment_income                           :integer          default("unfilled"), not null
#  had_social_security_income                           :integer          default("unfilled"), not null
#  had_social_security_or_retirement                    :integer          default("unfilled"), not null
#  had_tax_credit_disallowed                            :integer          default("unfilled"), not null
#  had_tips                                             :integer          default("unfilled"), not null
#  had_unemployment_income                              :integer          default("unfilled"), not null
#  had_w2s                                              :integer          default(0), not null
#  had_wages                                            :integer          default("unfilled"), not null
#  has_crypto_income                                    :boolean          default(FALSE)
#  has_primary_ip_pin                                   :integer          default(0), not null
#  has_spouse_ip_pin                                    :integer          default(0), not null
#  has_ssn_of_alimony_recipient                         :integer          default("unfilled"), not null
#  hashed_primary_ssn                                   :string
#  hashed_spouse_ssn                                    :string
#  home_location                                        :integer
#  homeless_youth                                       :integer          default(0), not null
#  income_over_limit                                    :integer          default("unfilled"), not null
#  interview_timing_preference                          :string
#  irs_language_preference                              :integer
#  issued_identity_pin                                  :integer          default("unfilled"), not null
#  job_count                                            :integer
#  lived_with_spouse                                    :integer          default("unfilled"), not null
#  locale                                               :string
#  made_estimated_tax_payments                          :integer          default("unfilled"), not null
#  made_estimated_tax_payments_amount                   :decimal(12, 2)
#  married                                              :integer          default("unfilled"), not null
#  multiple_states                                      :integer          default("unfilled"), not null
#  navigator_has_verified_client_identity               :boolean
#  navigator_name                                       :string
#  need_itin_help                                       :integer          default("unfilled"), not null
#  needs_help_2016                                      :integer          default("unfilled"), not null
#  needs_help_2018                                      :integer          default("unfilled"), not null
#  needs_help_2019                                      :integer          default("unfilled"), not null
#  needs_help_2020                                      :integer          default("unfilled"), not null
#  needs_help_2021                                      :integer          default("unfilled"), not null
#  needs_help_2022                                      :integer          default("unfilled"), not null
#  needs_help_current_year                              :integer          default("unfilled"), not null
#  needs_help_previous_year_1                           :integer          default("unfilled"), not null
#  needs_help_previous_year_2                           :integer          default("unfilled"), not null
#  needs_help_previous_year_3                           :integer          default("unfilled"), not null
#  needs_to_flush_searchable_data_set_at                :datetime
#  no_eligibility_checks_apply                          :integer          default("unfilled"), not null
#  no_ssn                                               :integer          default("unfilled"), not null
#  not_full_time_student                                :integer          default(0), not null
#  other_income_types                                   :string
#  paid_alimony                                         :integer          default("unfilled"), not null
#  paid_charitable_contributions                        :integer          default("unfilled"), not null
#  paid_dependent_care                                  :integer          default("unfilled"), not null
#  paid_local_tax                                       :integer          default("unfilled"), not null
#  paid_medical_expenses                                :integer          default("unfilled"), not null
#  paid_mortgage_interest                               :integer          default("unfilled"), not null
#  paid_post_secondary_educational_expenses             :integer          default("unfilled"), not null
#  paid_retirement_contributions                        :integer          default("unfilled"), not null
#  paid_school_supplies                                 :integer          default("unfilled"), not null
#  paid_self_employment_expenses                        :integer          default("unfilled"), not null
#  paid_student_loan_interest                           :integer          default("unfilled"), not null
#  phone_carrier                                        :string
#  phone_number                                         :string
#  phone_number_can_receive_texts                       :integer          default("unfilled"), not null
#  phone_number_type                                    :string
#  preferred_interview_language                         :string
#  preferred_name                                       :string
#  preferred_written_language                           :string
#  presidential_campaign_fund_donation                  :integer          default("unfilled"), not null
#  primary_active_armed_forces                          :integer          default(0), not null
#  primary_birth_date                                   :date
#  primary_consented_to_service                         :integer          default("unfilled"), not null
#  primary_consented_to_service_ip                      :inet
#  primary_first_name                                   :string
#  primary_ip_pin                                       :text
#  primary_job_title                                    :string
#  primary_last_four_ssn                                :text
#  primary_last_name                                    :string
#  primary_middle_initial                               :string
#  primary_prior_year_agi_amount                        :integer
#  primary_prior_year_signature_pin                     :string
#  primary_signature_pin                                :text
#  primary_signature_pin_at                             :datetime
#  primary_ssn                                          :text
#  primary_suffix                                       :string
#  primary_tin_type                                     :integer
#  primary_us_citizen                                   :integer          default("unfilled"), not null
#  primary_visa                                         :integer          default("unfilled"), not null
#  product_year                                         :integer          not null
#  receive_written_communication                        :integer          default("unfilled"), not null
#  received_advance_ctc_payment                         :integer
#  received_alimony                                     :integer          default("unfilled"), not null
#  received_homebuyer_credit                            :integer          default("unfilled"), not null
#  received_irs_letter                                  :integer          default("unfilled"), not null
#  received_stimulus_payment                            :integer          default("unfilled"), not null
#  referrer                                             :string
#  refund_payment_method                                :integer          default("unfilled"), not null
#  register_to_vote                                     :integer          default("unfilled"), not null
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
#  searchable_data                                      :tsvector
#  separated                                            :integer          default("unfilled"), not null
#  separated_year                                       :string
#  signature_method                                     :integer          default("online"), not null
#  sms_notification_opt_in                              :integer          default("unfilled"), not null
#  sms_phone_number                                     :string
#  sms_phone_number_verified_at                         :datetime
#  sold_a_home                                          :integer          default("unfilled"), not null
#  sold_assets                                          :integer          default("unfilled"), not null
#  source                                               :string
#  spouse_active_armed_forces                           :integer          default(0)
#  spouse_auth_token                                    :string
#  spouse_birth_date                                    :date
#  spouse_consented_to_service                          :integer          default("unfilled"), not null
#  spouse_consented_to_service_at                       :datetime
#  spouse_consented_to_service_ip                       :inet
#  spouse_email_address                                 :citext
#  spouse_filed_prior_tax_year                          :integer          default(0), not null
#  spouse_first_name                                    :string
#  spouse_had_disability                                :integer          default("unfilled"), not null
#  spouse_ip_pin                                        :text
#  spouse_issued_identity_pin                           :integer          default("unfilled"), not null
#  spouse_job_title                                     :string
#  spouse_last_four_ssn                                 :text
#  spouse_last_name                                     :string
#  spouse_middle_initial                                :string
#  spouse_phone_number                                  :string
#  spouse_prior_year_agi_amount                         :integer
#  spouse_prior_year_signature_pin                      :string
#  spouse_signature_pin                                 :text
#  spouse_signature_pin_at                              :datetime
#  spouse_ssn                                           :text
#  spouse_suffix                                        :string
#  spouse_tin_type                                      :integer
#  spouse_us_citizen                                    :integer          default("unfilled"), not null
#  spouse_visa                                          :integer          default("unfilled"), not null
#  spouse_was_blind                                     :integer          default("unfilled"), not null
#  spouse_was_full_time_student                         :integer          default("unfilled"), not null
#  state                                                :string
#  state_of_residence                                   :string
#  street_address                                       :string
#  street_address2                                      :string
#  tax_credit_disallowed_year                           :integer
#  timezone                                             :string
#  triage_filing_frequency                              :integer          default("unfilled"), not null
#  triage_filing_status                                 :integer          default("unfilled"), not null
#  triage_income_level                                  :integer          default("unfilled"), not null
#  triage_vita_income_ineligible                        :integer          default("unfilled"), not null
#  type                                                 :string
#  urbanization                                         :string
#  use_primary_name_for_name_control                    :boolean          default(FALSE)
#  used_itin_certifying_acceptance_agent                :boolean          default(FALSE), not null
#  usps_address_late_verification_attempts              :integer          default(0)
#  usps_address_verified_at                             :datetime
#  viewed_at_capacity                                   :boolean          default(FALSE)
#  wants_to_itemize                                     :integer          default("unfilled"), not null
#  was_blind                                            :integer          default("unfilled"), not null
#  was_full_time_student                                :integer          default("unfilled"), not null
#  widowed                                              :integer          default("unfilled"), not null
#  widowed_year                                         :string
#  with_general_navigator                               :boolean          default(FALSE)
#  with_incarcerated_navigator                          :boolean          default(FALSE)
#  with_limited_english_navigator                       :boolean          default(FALSE)
#  with_unhoused_navigator                              :boolean          default(FALSE)
#  zip_code                                             :string
#  created_at                                           :datetime         not null
#  updated_at                                           :datetime         not null
#  client_id                                            :bigint
#  matching_previous_year_intake_id                     :bigint
#  primary_drivers_license_id                           :bigint
#  spouse_drivers_license_id                            :bigint
#  visitor_id                                           :string
#  vita_partner_id                                      :bigint
#  with_drivers_license_photo_id                        :boolean          default(FALSE)
#  with_itin_taxpayer_id                                :boolean          default(FALSE)
#  with_other_state_photo_id                            :boolean          default(FALSE)
#  with_passport_photo_id                               :boolean          default(FALSE)
#  with_social_security_taxpayer_id                     :boolean          default(FALSE)
#  with_vita_approved_photo_id                          :boolean          default(FALSE)
#  with_vita_approved_taxpayer_id                       :boolean          default(FALSE)
#
# Indexes
#
#  index_intakes_on_canonical_email_address                (canonical_email_address)
#  index_intakes_on_client_id                              (client_id)
#  index_intakes_on_completed_at                           (completed_at) WHERE (completed_at IS NOT NULL)
#  index_intakes_on_email_address                          (email_address)
#  index_intakes_on_email_domain                           (email_domain)
#  index_intakes_on_hashed_primary_ssn                     (hashed_primary_ssn)
#  index_intakes_on_matching_previous_year_intake_id       (matching_previous_year_intake_id)
#  index_intakes_on_needs_to_flush_searchable_data_set_at  (needs_to_flush_searchable_data_set_at) WHERE (needs_to_flush_searchable_data_set_at IS NOT NULL)
#  index_intakes_on_phone_number                           (phone_number)
#  index_intakes_on_primary_consented_to_service           (primary_consented_to_service)
#  index_intakes_on_primary_drivers_license_id             (primary_drivers_license_id)
#  index_intakes_on_searchable_data                        (searchable_data) USING gin
#  index_intakes_on_sms_phone_number                       (sms_phone_number)
#  index_intakes_on_spouse_drivers_license_id              (spouse_drivers_license_id)
#  index_intakes_on_spouse_email_address                   (spouse_email_address)
#  index_intakes_on_type                                   (type)
#  index_intakes_on_vita_partner_id                        (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (matching_previous_year_intake_id => intakes.id)
#  fk_rails_...  (primary_drivers_license_id => drivers_licenses.id)
#  fk_rails_...  (spouse_drivers_license_id => drivers_licenses.id)
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
class Intake::GyrIntake < Intake
  enum adopted_child: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :adopted_child
  enum already_applied_for_stimulus: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :already_applied_for_stimulus
  enum bought_energy_efficient_items: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :bought_energy_efficient_items
  enum bought_employer_health_insurance: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :bought_employer_health_insurance
  enum bought_marketplace_health_insurance: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :bought_marketplace_health_insurance
  enum balance_pay_from_bank: { unfilled: 0, yes: 1, no: 2 }, _prefix: :balance_pay_from_bank
  enum claimed_by_another: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :claimed_by_another
  enum demographic_questions_opt_in: { unfilled: 0, yes: 1, no: 2 }, _prefix: :demographic_questions_opt_in
  enum demographic_english_conversation: { unfilled: 0, very_well: 1, well: 2 , not_well: 3, not_at_all: 4, prefer_not_to_answer: 5}, _prefix: :demographic_english_conversation
  enum demographic_english_reading: { unfilled: 0, very_well: 1, well: 2 , not_well: 3, not_at_all: 4, prefer_not_to_answer: 5}, _prefix: :demographic_english_reading
  enum demographic_disability: { unfilled: 0, yes: 1, no: 2, prefer_not_to_answer: 3 }, _prefix: :demographic_disability
  enum demographic_veteran: { unfilled: 0, yes: 1, no: 2, prefer_not_to_answer: 3 }, _prefix: :demographic_veteran
  enum demographic_primary_ethnicity: { unfilled: 0, hispanic_latino: 1, not_hispanic_latino: 2, prefer_not_to_answer: 3 }, _prefix: :demographic_primary_ethnicity
  enum demographic_spouse_ethnicity: { unfilled: 0, hispanic_latino: 1, not_hispanic_latino: 2, prefer_not_to_answer: 3 }, _prefix: :demographic_spouse_ethnicity
  enum divorced: { unfilled: 0, yes: 1, no: 2 }, _prefix: :divorced
  enum ever_married: { unfilled: 0, yes: 1, no: 2 }, _prefix: :ever_married
  enum ever_owned_home: { unfilled: 0, yes: 1, no: 2 }, _prefix: :ever_owned_home
  enum feeling_about_taxes: { unfilled: 0, positive: 1, neutral: 2, negative: 3 }, _prefix: :feeling_about_taxes
  enum filing_for_stimulus: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :filing_for_stimulus
  enum filing_joint: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :filing_joint
  enum got_married_during_tax_year: { unfilled: 0, yes: 1, no: 2}, _prefix: :got_married_during_tax_year
  enum had_asset_sale_income: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_asset_sale_income
  enum had_debt_forgiven: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_debt_forgiven
  enum had_dependents: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_dependents
  enum had_disability: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_disability
  enum had_disability_income: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_disability_income
  enum had_disaster_loss: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_disaster_loss
  enum had_farm_income: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_farm_income
  enum had_gambling_income: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_gambling_income
  enum had_hsa: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_hsa
  enum had_interest_income: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_interest_income
  enum had_local_tax_refund: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_local_tax_refund
  enum had_medicaid_medicare: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_medicaid_medicare
  enum had_other_income: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_other_income
  enum had_rental_income: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_rental_income
  enum had_retirement_income: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_retirement_income
  enum had_self_employment_income: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_self_employment_income
  enum had_social_security_income: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_social_security_income
  enum had_social_security_or_retirement: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_social_security_or_retirement
  enum had_tax_credit_disallowed: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_tax_credit_disallowed
  enum had_tips: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_tips
  enum had_unemployment_income: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_unemployment_income
  enum had_wages: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_wages
  enum income_over_limit: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :income_over_limit
  enum issued_identity_pin: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :issued_identity_pin
  enum lived_with_spouse: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :lived_with_spouse
  enum made_estimated_tax_payments: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :made_estimated_tax_payments
  enum married: { unfilled: 0, yes: 1, no: 2 }, _prefix: :married
  enum multiple_states: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :multiple_states
  enum needs_help_2016: { unfilled: 0, yes: 1, no: 2 }, _prefix: :needs_help_2016 # TODO: drop this column, it's not populated on anything in `intakes`
  enum needs_help_2018: { unfilled: 0, yes: 1, no: 2 }, _prefix: :needs_help_2018
  enum needs_help_2019: { unfilled: 0, yes: 1, no: 2 }, _prefix: :needs_help_2019
  enum needs_help_2020: { unfilled: 0, yes: 1, no: 2 }, _prefix: :needs_help_2020
  enum needs_help_2021: { unfilled: 0, yes: 1, no: 2 }, _prefix: :needs_help_2021
  enum needs_help_2022: { unfilled: 0, yes: 1, no: 2 }, _prefix: :needs_help_2022
  enum needs_help_previous_year_3: {unfilled: 0, yes: 1, no: 2}, _prefix: :needs_help_previous_year_3
  enum needs_help_previous_year_2: {unfilled: 0, yes: 1, no: 2}, _prefix: :needs_help_previous_year_2
  enum needs_help_previous_year_1: {unfilled: 0, yes: 1, no: 2}, _prefix: :needs_help_previous_year_1
  enum needs_help_current_year: {unfilled: 0, yes: 1, no: 2}, _prefix: :needs_help_current_year
  enum no_eligibility_checks_apply: { unfilled: 0, yes: 1, no: 2 }, _prefix: :no_eligibility_checks_apply
  enum no_ssn: { unfilled: 0, yes: 1, no: 2 }, _prefix: :no_ssn
  enum paid_alimony: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :paid_alimony
  enum paid_charitable_contributions: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :paid_charitable_contributions
  enum paid_dependent_care: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :paid_dependent_care
  enum paid_local_tax: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :paid_local_tax
  enum paid_medical_expenses: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :paid_medical_expenses
  enum paid_mortgage_interest: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :paid_mortgage_interest
  enum paid_retirement_contributions: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :paid_retirement_contributions
  enum paid_school_supplies: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :paid_school_supplies
  enum paid_student_loan_interest: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :paid_student_loan_interest
  enum phone_number_can_receive_texts: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :phone_number_can_receive_texts
  enum primary_us_citizen: { unfilled: 0, yes: 1, no: 2 }, _prefix: :primary_us_citizen
  enum primary_visa: { unfilled: 0, yes: 1, no: 2 }, _prefix: :primary_visa
  enum received_alimony: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :received_alimony
  enum received_homebuyer_credit: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :received_homebuyer_credit
  enum received_irs_letter: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :received_irs_letter
  enum received_stimulus_payment: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :received_stimulus_payment
  enum reported_asset_sale_loss: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :reported_asset_sale_loss
  enum reported_self_employment_loss: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :reported_self_employment_loss
  enum satisfaction_face: { unfilled: 0, positive: 1, neutral: 2, negative: 3 }, _prefix: :satisfaction_face
  enum savings_split_refund: { unfilled: 0, yes: 1, no: 2 }, _prefix: :savings_split_refund
  enum savings_purchase_bond: { unfilled: 0, yes: 1, no: 2 }, _prefix: :savings_purchase_bond
  enum separated: { unfilled: 0, yes: 1, no: 2 }, _prefix: :separated
  enum sold_a_home: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :sold_a_home
  enum sold_assets: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :sold_assets
  enum spouse_consented_to_service: { unfilled: 0, yes: 1, no: 2 }, _prefix: :spouse_consented_to_service
  enum spouse_had_disability: { unfilled: 0, yes: 1, no: 2 }, _prefix: :spouse_had_disability
  enum spouse_issued_identity_pin: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :spouse_issued_identity_pin
  enum spouse_us_citizen: { unfilled: 0, yes: 1, no: 2 }, _prefix: :spouse_us_citizen
  enum spouse_was_full_time_student: { unfilled: 0, yes: 1, no: 2 }, _prefix: :spouse_was_full_time_student
  enum spouse_was_blind: { unfilled: 0, yes: 1, no: 2 }, _prefix: :spouse_was_blind
  enum spouse_visa: { unfilled: 0, yes: 1, no: 2 }, _prefix: :spouse_visa
  enum was_blind: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :was_blind
  enum was_full_time_student: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :was_full_time_student
  enum widowed: { unfilled: 0, yes: 1, no: 2 }, _prefix: :widowed
  enum wants_to_itemize: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :wants_to_itemize
  enum received_advance_ctc_payment: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :received_advance_ctc_payment
  enum need_itin_help: { unfilled: 0, yes: 1, no: 2 }, _prefix: :need_itin_help
  enum triage_income_level: {
    "unfilled" => 0,
    "zero" => 1,
    "1_to_12500" => 2,
    "12500_to_25000" => 3,
    "25000_to_40000" => 4,
    "40000_to_66000" => 5,
    "66000_to_79000" => 6,
    "over_79000" => 7,
  }, _prefix: :triage_income_level
  enum triage_filing_status: { unfilled: 0, single: 1, jointly: 2 }, _prefix: :triage_filing_status
  enum triage_filing_frequency: { unfilled: 0, every_year: 1, some_years: 2, not_filed: 3 }, _prefix: :triage_filing_frequency
  enum triage_vita_income_ineligible: { unfilled: 0, yes: 1, no: 2 }, _prefix: :triage_vita_income_ineligible
  enum had_scholarships: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_scholarships
  enum had_cash_check_digital_assets: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_cash_check_digital_assets
  enum has_ssn_of_alimony_recipient: { unfilled: 0, yes: 1, no: 2 }, _prefix: :has_ssn_of_alimony_recipient
  enum contributed_to_ira: { unfilled: 0, yes: 1, no: 2 }, _prefix: :contributed_to_ira
  enum contributed_to_roth_ira: { unfilled: 0, yes: 1, no: 2 }, _prefix: :contributed_to_roth_ira
  enum contributed_to_401k: { unfilled: 0, yes: 1, no: 2 }, _prefix: :contributed_to_401k
  enum contributed_to_other_retirement_account: { unfilled: 0, yes: 1, no: 2 }, _prefix: :contributed_to_other_retirement_account
  enum paid_post_secondary_educational_expenses: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :paid_post_secondary_educational_expenses
  enum paid_self_employment_expenses: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :paid_self_employment_expenses
  enum had_capital_loss_carryover: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_capital_loss_carryover
  enum receive_written_communication: { unfilled: 0, yes: 1, no: 2 }, _prefix: :receive_written_communication
  enum presidential_campaign_fund_donation: { unfilled: 0, primary: 1, spouse: 2, primary_and_spouse: 3 }, _prefix: :presidential_campaign_fund_donation
  enum register_to_vote: { unfilled: 0, yes: 1, no: 2 }, _prefix: :register_to_vote

  belongs_to :matching_previous_year_intake, class_name: "Intake::GyrIntake", optional: true

  scope :previous_year_completed_intakes, -> { where.not(product_year: Rails.configuration.product_year).joins(:tax_returns).where(tax_returns: {current_state: TaxReturnStateMachine::INCLUDED_IN_PREVIOUS_YEAR_COMPLETED_INTAKES})}

  after_save do
    if saved_change_to_completed_at?(from: nil)
      InteractionTrackingService.record_incoming_interaction(client, set_flag: false) # client completed intake
    elsif completed_at.present?
      InteractionTrackingService.record_internal_interaction(client) # user updated completed intake
    end
  end

  after_save_commit { SearchIndexer.refresh_filterable_properties([client_id]) }
  after_destroy_commit { SearchIndexer.refresh_filterable_properties([client_id]) }

  def matching_previous_year_intakes
    attrs = [:primary_birth_date, :hashed_primary_ssn]
    DeduplicationService.duplicates(self, *attrs, from_scope: self.class.previous_year_completed_intakes)
  end

  def triaged_intake?
    !(triage_income_level_unfilled? && triage_filing_status_unfilled? && triage_filing_frequency_unfilled? && triage_vita_income_ineligible_unfilled?)
  end

  def self.current_tax_year
    Rails.application.config.gyr_current_tax_year.to_i
  end

  def most_recent_filing_year
    filing_years.first || MultiTenantService.new(:gyr).current_tax_year
  end

  def most_recent_needs_help_or_filing_year
    return filing_years.first if filing_years.first.present?
    return MultiTenantService.new(:gyr).current_tax_year - 1 if needs_help_previous_year_1_yes?
    return MultiTenantService.new(:gyr).current_tax_year - 2 if needs_help_previous_year_2_yes?
    return MultiTenantService.new(:gyr).current_tax_year - 3 if needs_help_previous_year_3_yes?

    MultiTenantService.new(:gyr).current_tax_year
  end

  def year_before_most_recent_filing_year
    most_recent_filing_year && most_recent_filing_year - 1
  end

  def probable_previous_year_intake
    return nil unless primary_last_four_ssn && primary_first_name && primary_last_name && primary_birth_date

    lookup_attributes = {
      type: "Intake::GyrIntake",
      primary_birth_date: primary_birth_date,
      primary_first_name: primary_first_name,
      primary_last_name: primary_last_name
    }

    previous_options = Intake.where(
      lookup_attributes
    ).where(
      'product_year < ?', product_year
    ).order(product_year: :desc).to_a
    previous_options.concat(Archived::Intake2021.where(lookup_attributes).to_a)

    previous_options&.find { |po| po.primary_last_four_ssn.to_s == primary_last_four_ssn.to_s } # last_four_ssn is encrypted, so we need to manually loop
  end

  def relevant_document_types
    DocumentTypes::ALL_TYPES.select do |doc_type_class|
      doc_type_class.relevant_to?(self)
    end
  end

  def relevant_intake_document_types
    Navigation::DocumentNavigation::FLOW.map do |doc_type_controller|
      doc_type = doc_type_controller.document_type
      doc_type if doc_type && doc_type.relevant_to?(self)
    end.compact.uniq
  end

  def document_types_definitely_needed
    relevant_document_types.select(&:needed_if_relevant?).reject do |document_type|
      document_types = if document_type == DocumentTypes::Identity
                         DocumentTypes::IDENTITY_TYPES.map(&:key)
                       elsif document_type == DocumentTypes::SsnItin
                         DocumentTypes::SECONDARY_IDENTITY_TYPES.map(&:key)
                       else
                         document_type.key
                       end
      documents.where(document_type: document_types).present?
    end
  end

  # create a faux bank account to turn bank account data into a BankAccount object
  def bank_account
    return nil unless bank_account_number || bank_name || bank_routing_number

    type = BankAccount.account_types.keys.include?(bank_account_type) ? bank_account_type : nil
    @bank_account ||= BankAccount.new(account_type: type, bank_name: bank_name, account_number: bank_account_number, routing_number: bank_routing_number)
  end

  def has_duplicate?
    duplicates.exists?
  end

  def document_types_possibly_needed
    relevant_document_types.reject(&:needed_if_relevant?).reject do |document_type|
      document_type == DocumentTypes::Other
    end.reject do |document_type|
      documents.where(document_type: document_type.key).present?
    end
  end

  def filing_jointly?
    filing_joint_yes?
  end

  def self.opted_out_gyr_intakes(email)
    Intake::GyrIntake.where(email_address: email).where(email_notification_opt_in: 'no')
  end

  def written_language_preference_english?
    receive_written_communication_no? || ["english", "inglés", "ingles", "inglesa", "en"].include?(preferred_written_language&.downcase)
  end

  def preferred_written_language_string
    I18n.t("general.written_language_options.#{preferred_written_language}", default: nil) || preferred_written_language&.capitalize
  end
end
