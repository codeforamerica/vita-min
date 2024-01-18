# == Schema Information
#
# Table name: intakes
#
#  id                                                   :bigint           not null, primary key
#  additional_info                                      :string
#  adopted_child                                        :integer          default(0), not null
#  advance_ctc_amount_received                          :integer
#  advance_ctc_entry_method                             :integer          default(0), not null
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
#  cannot_claim_me_as_a_dependent                       :integer          default(0), not null
#  canonical_email_address                              :string
#  city                                                 :string
#  claim_eitc                                           :integer          default(0), not null
#  claim_owed_stimulus_money                            :integer          default("unfilled"), not null
#  claimed_by_another                                   :integer          default(0), not null
#  completed_at                                         :datetime
#  completed_yes_no_questions_at                        :datetime
#  consented_to_legal                                   :integer          default(0), not null
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
#  ever_married                                         :integer          default(0), not null
#  ever_owned_home                                      :integer          default(0), not null
#  exceeded_investment_income_limit                     :integer          default(0)
#  feedback                                             :string
#  feeling_about_taxes                                  :integer          default(0), not null
#  filed_2020                                           :integer          default(0), not null
#  filed_prior_tax_year                                 :integer          default(0), not null
#  filing_for_stimulus                                  :integer          default(0), not null
#  filing_joint                                         :integer          default(0), not null
#  final_info                                           :string
#  former_foster_youth                                  :integer          default(0), not null
#  full_time_student_less_than_five_months              :integer          default(0), not null
#  got_married_during_tax_year                          :integer          default(0), not null
#  had_asset_sale_income                                :integer          default(0), not null
#  had_capital_loss_carryover                           :integer          default(0), not null
#  had_cash_check_digital_assets                        :integer          default(0), not null
#  had_debt_forgiven                                    :integer          default(0), not null
#  had_dependents                                       :integer          default(0), not null
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
#  had_w2s                                              :integer          default(0), not null
#  had_wages                                            :integer          default(0), not null
#  has_crypto_income                                    :boolean          default(FALSE)
#  has_primary_ip_pin                                   :integer          default(0), not null
#  has_spouse_ip_pin                                    :integer          default(0), not null
#  has_ssn_of_alimony_recipient                         :integer          default(0), not null
#  hashed_primary_ssn                                   :string
#  hashed_spouse_ssn                                    :string
#  home_location                                        :integer
#  homeless_youth                                       :integer          default(0), not null
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
#  not_full_time_student                                :integer          default(0), not null
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
#  spouse_active_armed_forces                           :integer          default(0)
#  spouse_auth_token                                    :string
#  spouse_birth_date                                    :date
#  spouse_consented_to_service                          :integer          default(0), not null
#  spouse_consented_to_service_at                       :datetime
#  spouse_consented_to_service_ip                       :inet
#  spouse_email_address                                 :citext
#  spouse_filed_prior_tax_year                          :integer          default(0), not null
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
#  spouse_was_blind                                     :integer          default(0), not null
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
#  was_blind                                            :integer          default(0), not null
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
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#

class Intake < ApplicationRecord
  include PgSearch::Model

  def self.searchable_fields
    [:client_id, :primary_first_name, :primary_last_name, :preferred_name, :spouse_first_name, :spouse_last_name, :email_address, :phone_number, :sms_phone_number]
  end

  pg_search_scope :search, against: searchable_fields, using: { tsearch: { prefix: true, tsvector_column: 'searchable_data' } }

  has_many :documents, dependent: :destroy
  has_many :dependents, -> { order(created_at: :asc) }, inverse_of: :intake, dependent: :destroy
  has_many :completed_w2s, -> { order(created_at: :asc).where.not(completed_at: nil) }, class_name: 'W2', inverse_of: :intake, dependent: :destroy
  has_many :w2s_including_incomplete, -> { order(created_at: :asc) }, class_name: 'W2', inverse_of: :intake, dependent: :destroy
  has_one :triage, dependent: :destroy
  belongs_to :client, inverse_of: :intake, optional: true
  has_many :tax_returns, through: :client
  has_many :experiment_participants, as: :record
  has_one :vita_partner, through: :client
  accepts_nested_attributes_for :dependents, allow_destroy: true
  scope :completed_yes_no_questions, -> { where.not(completed_yes_no_questions_at: nil) }
  validates :email_address, 'valid_email_2/email': true
  validates :phone_number, :sms_phone_number, allow_blank: true, e164_phone: true
  validates_presence_of :visitor_id
  validates_presence_of :product_year

  before_validation do
    self.primary_ssn = self.primary_ssn.remove(/\D/) if primary_ssn_changed? && self.primary_ssn
    self.spouse_ssn = self.spouse_ssn.remove(/\D/) if spouse_ssn_changed? && self.spouse_ssn
  end

  before_save do
    self.needs_to_flush_searchable_data_set_at = Time.current
    if email_address.present?
      self.email_domain = email_address.split('@').last.downcase
      self.canonical_email_address = CanonicalEmail.get(email_address)
    end
    if primary_ssn_changed?
      self.primary_last_four_ssn = primary_ssn&.last(4)
      self.hashed_primary_ssn = DeduplicationService.sensitive_attribute_hashed(self, :primary_ssn)
    end
    if spouse_ssn_changed?
      self.spouse_last_four_ssn = spouse_ssn&.last(4)
      self.hashed_spouse_ssn = DeduplicationService.sensitive_attribute_hashed(self, :spouse_ssn)
    end
  end

  before_save do
    if client_id_was && client_id && client_id_was != client_id
      raise "client_id of #{self.class.name} changed -- #{client_id_was} vs #{client_id}"
    end
  end

  after_save do
    if primary_consented_to_service_previously_changed?(to: "yes") && client.consented_to_service_at.blank?
      client.update(consented_to_service_at: updated_at)
    end
  end

  before_destroy do
    dependents.with_deleted.each(&:destroy!)
  end

  encrypts :primary_last_four_ssn, :spouse_last_four_ssn, :primary_ssn, :spouse_ssn, :bank_account_number, :primary_ip_pin, :primary_signature_pin, :spouse_signature_pin, :spouse_ip_pin

  enum already_filed: { unfilled: 0, yes: 1, no: 2 }, _prefix: :already_filed
  enum email_notification_opt_in: { unfilled: 0, yes: 1, no: 2 }, _prefix: :email_notification_opt_in
  enum sms_notification_opt_in: { unfilled: 0, yes: 1, no: 2 }, _prefix: :sms_notification_opt_in
  enum signature_method: { online: 0, in_person: 1 }, _prefix: :signature_method
  enum bank_account_type: { unfilled: 0, checking: 1, savings: 2, unspecified: 3 }, _prefix: :bank_account_type
  enum primary_consented_to_service: { unfilled: 0, yes: 1, no: 2 }, _prefix: :primary_consented_to_service
  enum refund_payment_method: { unfilled: 0, direct_deposit: 1, check: 2 }, _prefix: :refund_payment_method
  enum claim_owed_stimulus_money: { unfilled: 0, yes: 1, no: 2 }, _prefix: :claim_owed_stimulus_money
  enum primary_tin_type: { ssn: 0, itin: 1, none: 2, ssn_no_employment: 3 }, _prefix: :primary_tin_type
  enum spouse_tin_type: { ssn: 0, itin: 1, none: 2, ssn_no_employment: 3 }, _prefix: :spouse_tin_type
  enum irs_language_preference: { english: 0, spanish: 1, korean: 2, vietnamese: 3, russian: 4, arabic: 5, haitian_creole: 6, tagalog: 7, portuguese: 8, polish: 9, farsi: 10, french: 11, japanese: 12, gujarati: 13, punjabi: 14, khmer: 15, urdu: 16, bengali: 17, italian: 18, chinese_traditional: 19, chinese_simplified: 20 }, _prefix: :irs_language_preference

  NAVIGATOR_TYPES = {
    general: {
      param: "1",
      display_name: "General",
      field_name: :with_general_navigator
    },
    incarcerated: {
      param: "2",
      display_name: "Incarcerated/reentry",
      field_name: :with_incarcerated_navigator
    },
    limited_english: {
      param: "3",
      display_name: "Limited English",
      field_name: :with_limited_english_navigator
    },
    unhoused: {
      param: "4",
      display_name: "Unhoused",
      field_name: :with_unhoused_navigator
    }
  }

  scope :accessible_intakes, -> { where(primary_consented_to_service: "yes", product_year: Rails.configuration.product_year) }

  def duplicates
    return itin_duplicates if itin_applicant?
    return self.class.none if Rails.configuration.allow_magic_ssn && primary_ssn.present? && primary_ssn.start_with?('12345')
    return self.class.none unless hashed_primary_ssn.present?

    DeduplicationService.duplicates(self, :hashed_primary_ssn, from_scope: self.class.accessible_intakes)
  end

  # TODO: Delegate to client once backfill is run
  def primary_consented_to_service_at
    client.consented_to_service_at || read_attribute(:primary_consented_to_service_at)
  end

  def irs_language_preference_code
    return nil unless irs_language_preference
    preference_int = self.class.irs_language_preferences[irs_language_preference]
    "%03d" % preference_int
  end

  def itin_duplicates
    if email_address.present? && sms_phone_number.present?
      DeduplicationService.duplicates(self, :email_address, :primary_birth_date, from_scope: Intake::GyrIntake.accessible_intakes).or(
        DeduplicationService.duplicates(self, :sms_phone_number, :primary_birth_date, from_scope: Intake::GyrIntake.accessible_intakes)
      )
    elsif email_address.present?
      DeduplicationService.duplicates(self, :email_address, :primary_birth_date, from_scope: Intake::GyrIntake.accessible_intakes)
    elsif sms_phone_number.present?
      DeduplicationService.duplicates(self, :sms_phone_number, :primary_birth_date, from_scope: Intake::GyrIntake.accessible_intakes)
    else
      self.class.none
    end
  end

  def is_ctc?
    false
  end

  # Returns the phone number formatted for user display, e.g.: "(510) 555-1234"
  def formatted_phone_number
    PhoneParser.formatted_phone_number(phone_number)
  end

  def formatted_sms_phone_number
    PhoneParser.formatted_phone_number(sms_phone_number)
  end

  # Returns the sms phone number in the E164 standardized format, e.g.: "+15105551234"
  def standardized_sms_phone_number
    PhoneParser.normalize(sms_phone_number)
  end

  def referrer_domain
    URI.parse(referrer).host if referrer.present?
  end

  def state_of_residence_name
    States.name_for_key(state_of_residence)
  end

  def any_students?
    was_full_time_student_yes? ||
      spouse_was_full_time_student_yes? ||
      dependents.any?(&:was_student_yes?)
  end

  def spouse_name_or_placeholder
    return I18n.t("models.intake.your_spouse") unless spouse.first_name.present?
    spouse.first_and_last_name
  end

  def get_or_create_spouse_auth_token
    return spouse_auth_token if spouse_auth_token.present?

    new_token = SecureRandom.urlsafe_base64(8)
    update(spouse_auth_token: new_token)
    new_token
  end

  def filing_years
    tax_returns.pluck(:year).sort.reverse
  end

  def filer_count
    filing_jointly? ? 2 : 1
  end

  def include_bank_details?
    refund_payment_method_direct_deposit? || balance_pay_from_bank_yes?
  end

  def contact_info_filtered_by_preferences
    contact_info = {}
    contact_info[:sms_phone_number] = sms_phone_number if sms_notification_opt_in_yes?
    contact_info[:email] = email_address if email_notification_opt_in_yes?
    contact_info
  end

  def had_earned_income?
    (job_count&.> 0) || had_wages_yes? || had_self_employment_income_yes?
  end

  def persisted_dependents
    dependents.select(&:persisted?)
  end

  def had_dependents_under?(yrs)
    persisted_dependents.any? { |dependent| dependent.age_during(2020) < yrs }
  end

  def needs_help_with_backtaxes?
    MultiTenantService.new(:gyr).backtax_years.any? { |year| send("needs_help_#{year}_yes?") }
  end

  def update_or_create_13614c_document(filename)
    pdf = PdfFiller::F13614cPdf.new(self)
    ClientPdfDocument.create_or_update(
      output_file: pdf.output_file,
      document_type: pdf.document_type,
      client: client,
      filename: filename || pdf.output_filename
    )
  end

  def update_or_create_required_consent_pdf
    consent_pdf = PdfFiller::ConsentPdf.new(self)
    ClientPdfDocument.create_or_update(
      output_file: consent_pdf.output_file,
      document_type: consent_pdf.document_type,
      client: client,
      filename: consent_pdf.output_filename
    )
  end

  def address
    Address.new(
      zip_code: zip_code,
      street_address: street_address,
      street_address2: street_address2,
      city: city,
      state: state
    )
  end

  def set_navigator(param)
    _, navigator_type = NAVIGATOR_TYPES.find { |_, type| type[:param] == param }
    return unless navigator_type

    self.update(navigator_type[:field_name] => true)
  end

  def drop_off?
    tax_returns.pluck(:service_type).any? "drop_off"
  end

  def navigator_display_names
    names = []
    NAVIGATOR_TYPES.each do |_, type|
      if self.send(type[:field_name])
        names << type[:display_name]
      end
    end
    names.join(', ')
  end

  def new_record_token
    verifier = ActiveSupport::MessageVerifier.new(Rails.application.secret_key_base)
    verifier.generate(SecureRandom.base36(24))
  end

  def itin_applicant?
    need_itin_help_yes?
  end

  def filers
    if filing_jointly?
      [primary, spouse]
    else
      [primary]
    end
  end

  def primary
    Person.new(self, :primary)
  end

  def spouse
    Person.new(self, :spouse)
  end

  class Person
    attr_reader :first_name
    attr_reader :middle_initial
    attr_reader :last_name
    attr_reader :birth_date
    attr_reader :suffix
    attr_reader :tin_type
    attr_reader :ssn
    attr_reader :active_armed_forces

    def initialize(intake, primary_or_spouse)
      @primary_or_spouse = primary_or_spouse
      if primary_or_spouse == :primary
        @first_name = intake.primary_first_name
        @middle_initial = intake.primary_middle_initial
        @last_name = intake.primary_last_name
        @birth_date = intake.primary_birth_date
        @suffix = intake.primary_suffix
        @tin_type = intake.primary_tin_type
        @ssn = intake.primary_ssn
        @active_armed_forces = intake.primary_active_armed_forces
      elsif primary_or_spouse == :spouse
        @first_name = intake.spouse_first_name
        @middle_initial = intake.spouse_middle_initial
        @last_name = intake.spouse_last_name
        @birth_date = intake.spouse_birth_date
        @suffix = intake.spouse_suffix
        @tin_type = intake.spouse_tin_type
        @ssn = intake.spouse_ssn
        @active_armed_forces = intake.spouse_active_armed_forces
      end
    end

    def first_and_last_name
      return I18n.t("models.intake.your_spouse") if @primary_or_spouse == :spouse && @first_name.blank?

      parts = [@first_name, @last_name]
      parts << @suffix if @suffix.present?
      parts.join(' ')
    end

    def full_name
      parts = [@first_name, @middle_initial, @last_name]
      parts << @suffix if @suffix.present?
      parts.join(' ')
    end
  end

  def self.archived_columns
    ["needs_help_2017", "was_on_visa", "spouse_was_on_visa", "had_student_in_family"]
  end
  delegate *archived_columns, to: :intake_archive, allow_nil: true
  has_one :intake_archive, foreign_key: :id, dependent: :destroy

  self.ignored_columns = ["primary_consented_to_service_at"] + archived_columns
end
