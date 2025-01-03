# == Schema Information
#
# Table name: intakes
#
#  id                                                   :bigint           not null, primary key
#  additional_info                                      :string
#  adopted_child                                        :integer          default(0), not null
#  advance_ctc_amount_received                          :integer
#  advance_ctc_entry_method                             :integer          default("unfilled"), not null
#  already_applied_for_stimulus                         :integer          default(0), not null
#  already_filed                                        :integer          default("unfilled"), not null
#  balance_pay_from_bank                                :integer          default(0), not null
#  bank_account_number                                  :text
#  bank_account_type                                    :integer          default("unfilled"), not null
#  bank_name                                            :string
#  bank_routing_number                                  :string
#  bought_employer_health_insurance                     :integer          default(0), not null
#  bought_energy_efficient_items                        :integer
#  bought_marketplace_health_insurance                  :integer          default(0), not null
#  cannot_claim_me_as_a_dependent                       :integer          default("unfilled"), not null
#  canonical_email_address                              :string
#  city                                                 :string
#  claim_eitc                                           :integer          default("unfilled"), not null
#  claim_owed_stimulus_money                            :integer          default("unfilled"), not null
#  claimed_by_another                                   :integer          default(0), not null
#  completed_at                                         :datetime
#  completed_yes_no_questions_at                        :datetime
#  consented_to_legal                                   :integer          default("unfilled"), not null
#  continued_at_capacity                                :boolean          default(FALSE)
#  contributed_to_401k                                  :integer          default(0), not null
#  contributed_to_ira                                   :integer          default(0), not null
#  contributed_to_other_retirement_account              :integer          default(0), not null
#  contributed_to_roth_ira                              :integer          default(0), not null
#  current_step                                         :string
#  demographic_disability                               :integer          default(0), not null
#  demographic_english_conversation                     :integer          default(0), not null
#  demographic_english_reading                          :integer          default(0), not null
#  demographic_primary_american_indian_alaska_native    :boolean
#  demographic_primary_asian                            :boolean
#  demographic_primary_black_african_american           :boolean
#  demographic_primary_ethnicity                        :integer          default(0), not null
#  demographic_primary_native_hawaiian_pacific_islander :boolean
#  demographic_primary_prefer_not_to_answer_race        :boolean
#  demographic_primary_white                            :boolean
#  demographic_questions_hub_edit                       :boolean          default(FALSE)
#  demographic_questions_opt_in                         :integer          default(0), not null
#  demographic_spouse_american_indian_alaska_native     :boolean
#  demographic_spouse_asian                             :boolean
#  demographic_spouse_black_african_american            :boolean
#  demographic_spouse_ethnicity                         :integer          default(0), not null
#  demographic_spouse_native_hawaiian_pacific_islander  :boolean
#  demographic_spouse_prefer_not_to_answer_race         :boolean
#  demographic_spouse_white                             :boolean
#  demographic_veteran                                  :integer          default(0), not null
#  disallowed_ctc                                       :boolean
#  divorced                                             :integer          default(0), not null
#  divorced_year                                        :string
#  eip1_amount_received                                 :integer
#  eip1_and_2_amount_received_confidence                :integer
#  eip1_entry_method                                    :integer          default("unfilled"), not null
#  eip2_amount_received                                 :integer
#  eip2_entry_method                                    :integer          default("unfilled"), not null
#  eip3_amount_received                                 :integer
#  eip3_entry_method                                    :integer          default("unfilled"), not null
#  eip_only                                             :boolean
#  email_address                                        :citext
#  email_address_verified_at                            :datetime
#  email_domain                                         :string
#  email_notification_opt_in                            :integer          default("unfilled"), not null
#  ever_married                                         :integer          default(0), not null
#  ever_owned_home                                      :integer          default(0), not null
#  exceeded_investment_income_limit                     :integer          default("unfilled")
#  feedback                                             :string
#  feeling_about_taxes                                  :integer          default(0), not null
#  filed_2020                                           :integer          default(0), not null
#  filed_prior_tax_year                                 :integer          default("unfilled"), not null
#  filing_for_stimulus                                  :integer          default(0), not null
#  filing_joint                                         :integer          default(0), not null
#  final_info                                           :string
#  former_foster_youth                                  :integer          default("unfilled"), not null
#  full_time_student_less_than_five_months              :integer          default("unfilled"), not null
#  got_married_during_tax_year                          :integer          default(0), not null
#  had_asset_sale_income                                :integer          default(0), not null
#  had_capital_loss_carryover                           :integer          default(0), not null
#  had_cash_check_digital_assets                        :integer          default(0), not null
#  had_debt_forgiven                                    :integer          default(0), not null
#  had_dependents                                       :integer          default("unfilled"), not null
#  had_disability                                       :integer          default(0), not null
#  had_disability_income                                :integer          default(0), not null
#  had_disaster_loss                                    :integer          default(0), not null
#  had_disaster_loss_where                              :string
#  had_disqualifying_non_w2_income                      :integer
#  had_farm_income                                      :integer          default(0), not null
#  had_gambling_income                                  :integer          default(0), not null
#  had_hsa                                              :integer          default(0), not null
#  had_interest_income                                  :integer          default(0), not null
#  had_local_tax_refund                                 :integer          default(0), not null
#  had_medicaid_medicare                                :integer          default(0), not null
#  had_other_income                                     :integer          default(0), not null
#  had_rental_income                                    :integer          default(0), not null
#  had_retirement_income                                :integer          default(0), not null
#  had_scholarships                                     :integer          default(0), not null
#  had_self_employment_income                           :integer          default(0), not null
#  had_social_security_income                           :integer          default(0), not null
#  had_social_security_or_retirement                    :integer          default(0), not null
#  had_tax_credit_disallowed                            :integer          default(0), not null
#  had_tips                                             :integer          default(0), not null
#  had_unemployment_income                              :integer          default(0), not null
#  had_w2s                                              :integer          default("unfilled"), not null
#  had_wages                                            :integer          default(0), not null
#  has_crypto_income                                    :boolean          default(FALSE)
#  has_primary_ip_pin                                   :integer          default("unfilled"), not null
#  has_spouse_ip_pin                                    :integer          default("unfilled"), not null
#  has_ssn_of_alimony_recipient                         :integer          default(0), not null
#  hashed_primary_ssn                                   :string
#  hashed_spouse_ssn                                    :string
#  home_location                                        :integer
#  homeless_youth                                       :integer          default("unfilled"), not null
#  income_over_limit                                    :integer          default(0), not null
#  interview_timing_preference                          :string
#  irs_language_preference                              :integer
#  issued_identity_pin                                  :integer          default(0), not null
#  job_count                                            :integer
#  lived_with_spouse                                    :integer          default(0), not null
#  locale                                               :string
#  made_estimated_tax_payments                          :integer          default(0), not null
#  made_estimated_tax_payments_amount                   :decimal(12, 2)
#  married                                              :integer          default(0), not null
#  multiple_states                                      :integer          default(0), not null
#  navigator_has_verified_client_identity               :boolean
#  navigator_name                                       :string
#  need_itin_help                                       :integer          default(0), not null
#  needs_help_2016                                      :integer          default(0), not null
#  needs_help_2018                                      :integer          default(0), not null
#  needs_help_2019                                      :integer          default(0), not null
#  needs_help_2020                                      :integer          default(0), not null
#  needs_help_2021                                      :integer          default(0), not null
#  needs_help_2022                                      :integer          default(0), not null
#  needs_help_current_year                              :integer          default(0), not null
#  needs_help_previous_year_1                           :integer          default(0), not null
#  needs_help_previous_year_2                           :integer          default(0), not null
#  needs_help_previous_year_3                           :integer          default(0), not null
#  needs_to_flush_searchable_data_set_at                :datetime
#  no_eligibility_checks_apply                          :integer          default(0), not null
#  no_ssn                                               :integer          default(0), not null
#  not_full_time_student                                :integer          default("unfilled"), not null
#  other_income_types                                   :string
#  paid_alimony                                         :integer          default(0), not null
#  paid_charitable_contributions                        :integer          default(0), not null
#  paid_dependent_care                                  :integer          default(0), not null
#  paid_local_tax                                       :integer          default(0), not null
#  paid_medical_expenses                                :integer          default(0), not null
#  paid_mortgage_interest                               :integer          default(0), not null
#  paid_post_secondary_educational_expenses             :integer          default(0), not null
#  paid_retirement_contributions                        :integer          default(0), not null
#  paid_school_supplies                                 :integer          default(0), not null
#  paid_self_employment_expenses                        :integer          default(0), not null
#  paid_student_loan_interest                           :integer          default(0), not null
#  phone_carrier                                        :string
#  phone_number                                         :string
#  phone_number_can_receive_texts                       :integer          default(0), not null
#  phone_number_type                                    :string
#  preferred_interview_language                         :string
#  preferred_name                                       :string
#  preferred_written_language                           :string
#  presidential_campaign_fund_donation                  :integer          default(0), not null
#  primary_active_armed_forces                          :integer          default("unfilled"), not null
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
#  primary_us_citizen                                   :integer          default(0), not null
#  product_year                                         :integer          not null
#  receive_written_communication                        :integer          default(0), not null
#  received_advance_ctc_payment                         :integer
#  received_alimony                                     :integer          default(0), not null
#  received_homebuyer_credit                            :integer          default(0), not null
#  received_irs_letter                                  :integer          default(0), not null
#  received_stimulus_payment                            :integer          default(0), not null
#  referrer                                             :string
#  refund_payment_method                                :integer          default("unfilled"), not null
#  register_to_vote                                     :integer          default(0), not null
#  reported_asset_sale_loss                             :integer          default(0), not null
#  reported_self_employment_loss                        :integer          default(0), not null
#  requested_docs_token                                 :string
#  requested_docs_token_created_at                      :datetime
#  routed_at                                            :datetime
#  routing_criteria                                     :string
#  routing_value                                        :string
#  satisfaction_face                                    :integer          default(0), not null
#  savings_purchase_bond                                :integer          default(0), not null
#  savings_split_refund                                 :integer          default(0), not null
#  searchable_data                                      :tsvector
#  separated                                            :integer          default(0), not null
#  separated_year                                       :string
#  signature_method                                     :integer          default("online"), not null
#  sms_notification_opt_in                              :integer          default("unfilled"), not null
#  sms_phone_number                                     :string
#  sms_phone_number_verified_at                         :datetime
#  sold_a_home                                          :integer          default(0), not null
#  sold_assets                                          :integer          default(0), not null
#  source                                               :string
#  spouse_active_armed_forces                           :integer          default("unfilled")
#  spouse_auth_token                                    :string
#  spouse_birth_date                                    :date
#  spouse_consented_to_service                          :integer          default(0), not null
#  spouse_consented_to_service_at                       :datetime
#  spouse_consented_to_service_ip                       :inet
#  spouse_email_address                                 :citext
#  spouse_filed_prior_tax_year                          :integer          default("unfilled"), not null
#  spouse_first_name                                    :string
#  spouse_had_disability                                :integer          default(0), not null
#  spouse_ip_pin                                        :text
#  spouse_issued_identity_pin                           :integer          default(0), not null
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
#  spouse_us_citizen                                    :integer          default(0), not null
#  spouse_was_blind                                     :integer          default("unfilled"), not null
#  spouse_was_full_time_student                         :integer          default(0), not null
#  state                                                :string
#  state_of_residence                                   :string
#  street_address                                       :string
#  street_address2                                      :string
#  tax_credit_disallowed_year                           :integer
#  timezone                                             :string
#  triage_filing_frequency                              :integer          default(0), not null
#  triage_filing_status                                 :integer          default(0), not null
#  triage_income_level                                  :integer          default(0), not null
#  triage_vita_income_ineligible                        :integer          default(0), not null
#  type                                                 :string
#  urbanization                                         :string
#  use_primary_name_for_name_control                    :boolean          default(FALSE)
#  used_itin_certifying_acceptance_agent                :boolean          default(FALSE), not null
#  usps_address_late_verification_attempts              :integer          default(0)
#  usps_address_verified_at                             :datetime
#  viewed_at_capacity                                   :boolean          default(FALSE)
#  wants_to_itemize                                     :integer          default(0), not null
#  was_blind                                            :integer          default("unfilled"), not null
#  was_full_time_student                                :integer          default(0), not null
#  widowed                                              :integer          default(0), not null
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
class Intake::CtcIntake < Intake
  TEST_ENV_TAX_YEAR = 2023

  attribute :eip1_amount_received, :money
  attribute :eip2_amount_received, :money
  attribute :primary_prior_year_agi_amount, :money
  attribute :spouse_prior_year_agi_amount, :money

  enum had_dependents: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_dependents
  enum exceeded_investment_income_limit: { unfilled: 0, yes: 1, no: 2 }, _prefix: :exceeded_investment_income_limit
  enum eip1_entry_method: { unfilled: 0, calculated_amount: 1, did_not_receive: 2, manual_entry: 3 }, _prefix: :eip1_entry_method
  enum eip2_entry_method: { unfilled: 0, calculated_amount: 1, did_not_receive: 2, manual_entry: 3 }, _prefix: :eip2_entry_method
  enum eip3_entry_method: { unfilled: 0, calculated_amount: 1, did_not_receive: 2, manual_entry: 3 }, _prefix: :eip3_entry_method
  enum eip1_and_2_amount_received_confidence: { unfilled: 0, sure: 1, unsure: 2 }, _prefix: :eip1_and_2_amount_received_confidence
  enum advance_ctc_entry_method: { unfilled: 0, calculated_amount: 1, did_not_receive: 2, manual_entry: 3 }, _prefix: :advance_ctc_entry_method
  enum filed_prior_tax_year: { unfilled: 0, filed_full: 1, filed_non_filer: 2, did_not_file: 3 }, _prefix: :filed_prior_tax_year
  enum spouse_filed_prior_tax_year: { unfilled: 0, filed_full_separate: 3, filed_non_filer_separate: 4, did_not_file: 5, filed_together: 6 }, _prefix: :spouse_filed_prior_tax_year
  enum spouse_active_armed_forces: { unfilled: 0, yes: 1, no: 2 }, _prefix: :spouse_active_armed_forces
  enum cannot_claim_me_as_a_dependent: { unfilled: 0, yes: 1, no: 2 }, _prefix: :cannot_claim_me_as_a_dependent
  enum primary_active_armed_forces: { unfilled: 0, yes: 1, no: 2 }, _prefix: :primary_active_armed_forces
  enum has_primary_ip_pin: { unfilled: 0, yes: 1, no: 2 }, _prefix: :has_primary_ip_pin
  enum has_spouse_ip_pin: { unfilled: 0, yes: 1, no: 2 }, _prefix: :has_spouse_ip_pin
  enum consented_to_legal: { unfilled: 0, yes: 1, no: 2 }, _prefix: :consented_to_legal
  enum was_blind: { unfilled: 0, yes: 1, no: 2 }, _prefix: :was_blind
  enum spouse_was_blind: { unfilled: 0, yes: 1, no: 2 }, _prefix: :spouse_was_blind
  enum home_location: { fifty_states: 0, military_facility: 1, puerto_rico: 2, us_territory: 3, foreign_address: 4 }, _prefix: :home_location
  enum claim_eitc: { unfilled: 0, yes: 1, no: 2 }, _prefix: :claim_eitc
  enum former_foster_youth: { unfilled: 0, yes: 1, no: 2 }, _prefix: :former_foster_youth
  enum homeless_youth: { unfilled: 0, yes: 1, no: 2 }, _prefix: :homeless_youth
  enum not_full_time_student: { unfilled: 0, yes: 1, no: 2 }, _prefix: :not_full_time_student
  enum full_time_student_less_than_five_months: { unfilled: 0, yes: 1, no: 2 }, _prefix: :full_time_student_less_than_five_months
  enum had_w2s: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_w2s
  enum had_disqualifying_non_w2_income: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_disqualifying_non_w2_income
  scope :accessible_intakes, -> do
    sms_verified = where.not(sms_phone_number_verified_at: nil)
    email_verified = where.not(email_address_verified_at: nil)
    navigator_verified = where.not(navigator_has_verified_client_identity: nil)
    last_year_of_ctc = 2022
    sms_verified.or(email_verified).or(navigator_verified).where(product_year: last_year_of_ctc)
  end
  has_one :bank_account, inverse_of: :intake, foreign_key: :intake_id, dependent: :destroy
  belongs_to :primary_drivers_license, class_name: "DriversLicense", optional: true
  belongs_to :spouse_drivers_license, class_name: "DriversLicense", optional: true
  accepts_nested_attributes_for :bank_account, :primary_drivers_license, :spouse_drivers_license

  before_validation do
    attributes_to_change = self.changes_to_save.keys
    name_attributes = ["primary_first_name", "primary_last_name", "spouse_first_name", "spouse_last_name"]

    (attributes_to_change & name_attributes).each do |attribute|
      if self.attributes[attribute].present?
        new_value = self.attributes[attribute].split(/\s/).filter { |str| !str.empty? }.join(" ")
        self.assign_attributes(attribute => new_value)
      end
    end
  end

  PHOTO_ID_TYPES = {
    drivers_license: {
      display_name: "Drivers License",
      field_name: :with_drivers_license_photo_id
    },
    passport: {
      display_name: "US Passport",
      field_name: :with_passport_photo_id
    },
    other_state: {
      display_name: "Other State ID",
      field_name: :with_other_state_photo_id
    },
    vita_approved: {
      display_name: "Identification approved by my VITA site",
      field_name: :with_vita_approved_photo_id
    }
  }

  TAXPAYER_ID_TYPES = {
    social_security: {
      display_name: "Social Security card",
      field_name: :with_social_security_taxpayer_id
    },
    itin: {
      display_name: "Individual Taxpayer ID Number (ITIN) letter",
      field_name: :with_itin_taxpayer_id
    },
    vita_approved: {
      display_name: "Identification approved by my VITA site",
      field_name: :with_vita_approved_taxpayer_id
    }
  }

  def itin_applicant?
    false
  end

  def has_duplicate?
    duplicates.exists?
  end

  def document_types_definitely_needed
    []
  end

  def is_ctc?
    true
  end

  def default_tax_return
    if Rails.env.test?
      tax_returns.find_by(year: product_year - 1)
    else
      tax_returns.find_by(year: TEST_ENV_TAX_YEAR)
    end
  end

  # we dont currently ask for preferred name in the onboarding flow, so let's use primary first name to keep the app working for MVP
  def preferred_name
    read_attribute(:preferred_name) || primary_first_name
  end

  def photo_id_display_names
    names = []
    PHOTO_ID_TYPES.each do |_, type|
      if self.send(type[:field_name])
        names << type[:display_name]
      end
    end
    names.join(', ')
  end

  def taxpayer_id_display_names
    names = []
    TAXPAYER_ID_TYPES.each do |_, type|
      if self.send(type[:field_name])
        names << type[:display_name]
      end
    end
    names.join(', ')
  end

  def any_ip_pins?
    primary_ip_pin.present? || spouse_ip_pin.present? || dependents.any? { |d| d.ip_pin.present? }
  end

  def filing_jointly?
    client.tax_returns.last.filing_status_married_filing_jointly?
  end

  # Only use this when initially calculating the spouse's AGI for initial submission.
  # In all instances after, use the saved spouse_prior_year_agi_amount so that incorrect
  # answers to prior year filing questions do not affect submission values.
  def spouse_prior_year_agi_amount_computed
    if spouse_filed_prior_tax_year_filed_non_filer_separate?
      1
    elsif spouse_filed_prior_tax_year_filed_together? && primary_prior_year_agi_amount.present?
      primary_prior_year_agi_amount
    elsif spouse_filed_prior_tax_year_filed_full_separate? && spouse_prior_year_agi_amount.present?
      spouse_prior_year_agi_amount
    else
      0
    end
  end

  def puerto_rico_filing?
    home_location_puerto_rico?
  end

  def total_wages_amount
    completed_w2s.sum { |w2| w2.wages_amount.round } if completed_w2s.any?
  end

  def total_withholding_amount
    completed_w2s.sum { |w2| w2.federal_income_tax_withheld.round } if completed_w2s.any?
  end

  def benefits_eligibility
    Efile::BenefitsEligibility.new(tax_return: default_tax_return, dependents: dependents)
  end
end
