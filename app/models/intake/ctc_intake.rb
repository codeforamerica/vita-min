# == Schema Information
#
# Table name: intakes
#
#  id                                                   :bigint           not null, primary key
#  additional_info                                      :string
#  adopted_child                                        :integer          default(0), not null
#  advance_ctc_amount_received                          :integer
#  already_applied_for_stimulus                         :integer          default(0), not null
#  already_filed                                        :integer          default("unfilled"), not null
#  balance_pay_from_bank                                :integer          default(0), not null
#  bank_account_type                                    :integer          default("unfilled"), not null
#  bought_energy_efficient_items                        :integer
#  bought_health_insurance                              :integer          default(0), not null
#  cannot_claim_me_as_a_dependent                       :integer          default("unfilled"), not null
#  canonical_email_address                              :string
#  city                                                 :string
#  claim_owed_stimulus_money                            :integer          default("unfilled"), not null
#  claimed_by_another                                   :integer          default(0), not null
#  completed_at                                         :datetime
#  completed_yes_no_questions_at                        :datetime
#  consented_to_legal                                   :integer          default("unfilled"), not null
#  continued_at_capacity                                :boolean          default(FALSE)
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
#  demographic_questions_opt_in                         :integer          default(0), not null
#  demographic_spouse_american_indian_alaska_native     :boolean
#  demographic_spouse_asian                             :boolean
#  demographic_spouse_black_african_american            :boolean
#  demographic_spouse_ethnicity                         :integer          default(0), not null
#  demographic_spouse_native_hawaiian_pacific_islander  :boolean
#  demographic_spouse_prefer_not_to_answer_race         :boolean
#  demographic_spouse_white                             :boolean
#  demographic_veteran                                  :integer          default(0), not null
#  divorced                                             :integer          default(0), not null
#  divorced_year                                        :string
#  eip1_amount_received                                 :integer
#  eip1_and_2_amount_received_confidence                :integer
#  eip1_entry_method                                    :integer          default("unfilled"), not null
#  eip2_amount_received                                 :integer
#  eip2_entry_method                                    :integer          default("unfilled"), not null
#  eip3_amount_received                                 :integer
#  eip_only                                             :boolean
#  email_address                                        :citext
#  email_address_verified_at                            :datetime
#  email_domain                                         :string
#  email_notification_opt_in                            :integer          default("unfilled"), not null
#  encrypted_bank_account_number                        :string
#  encrypted_bank_account_number_iv                     :string
#  encrypted_bank_name                                  :string
#  encrypted_bank_name_iv                               :string
#  encrypted_bank_routing_number                        :string
#  encrypted_bank_routing_number_iv                     :string
#  encrypted_primary_ip_pin                             :string
#  encrypted_primary_ip_pin_iv                          :string
#  encrypted_primary_last_four_ssn                      :string
#  encrypted_primary_last_four_ssn_iv                   :string
#  encrypted_primary_signature_pin                      :string
#  encrypted_primary_signature_pin_iv                   :string
#  encrypted_primary_ssn                                :string
#  encrypted_primary_ssn_iv                             :string
#  encrypted_spouse_ip_pin                              :string
#  encrypted_spouse_ip_pin_iv                           :string
#  encrypted_spouse_last_four_ssn                       :string
#  encrypted_spouse_last_four_ssn_iv                    :string
#  encrypted_spouse_signature_pin                       :string
#  encrypted_spouse_signature_pin_iv                    :string
#  encrypted_spouse_ssn                                 :string
#  encrypted_spouse_ssn_iv                              :string
#  ever_married                                         :integer          default(0), not null
#  ever_owned_home                                      :integer          default(0), not null
#  feedback                                             :string
#  feeling_about_taxes                                  :integer          default(0), not null
#  filed_2020                                           :integer          default(0), not null
#  filed_prior_tax_year                                 :integer          default("unfilled"), not null
#  filing_for_stimulus                                  :integer          default(0), not null
#  filing_joint                                         :integer          default(0), not null
#  final_info                                           :string
#  had_asset_sale_income                                :integer          default(0), not null
#  had_debt_forgiven                                    :integer          default(0), not null
#  had_dependents                                       :integer          default("unfilled"), not null
#  had_disability                                       :integer          default(0), not null
#  had_disability_income                                :integer          default(0), not null
#  had_disaster_loss                                    :integer          default(0), not null
#  had_farm_income                                      :integer          default(0), not null
#  had_gambling_income                                  :integer          default(0), not null
#  had_hsa                                              :integer          default(0), not null
#  had_interest_income                                  :integer          default(0), not null
#  had_local_tax_refund                                 :integer          default(0), not null
#  had_other_income                                     :integer          default(0), not null
#  had_rental_income                                    :integer          default(0), not null
#  had_retirement_income                                :integer          default(0), not null
#  had_self_employment_income                           :integer          default(0), not null
#  had_social_security_income                           :integer          default(0), not null
#  had_social_security_or_retirement                    :integer          default(0), not null
#  had_student_in_family                                :integer          default(0), not null
#  had_tax_credit_disallowed                            :integer          default(0), not null
#  had_tips                                             :integer          default(0), not null
#  had_unemployment_income                              :integer          default(0), not null
#  had_wages                                            :integer          default(0), not null
#  has_primary_ip_pin                                   :integer          default("unfilled"), not null
#  has_spouse_ip_pin                                    :integer          default("unfilled"), not null
#  hashed_primary_ssn                                   :string
#  income_over_limit                                    :integer          default(0), not null
#  interview_timing_preference                          :string
#  issued_identity_pin                                  :integer          default(0), not null
#  job_count                                            :integer
#  lived_with_spouse                                    :integer          default(0), not null
#  locale                                               :string
#  made_estimated_tax_payments                          :integer          default(0), not null
#  married                                              :integer          default(0), not null
#  multiple_states                                      :integer          default(0), not null
#  navigator_has_verified_client_identity               :boolean
#  navigator_name                                       :string
#  needs_help_2016                                      :integer          default(0), not null
#  needs_help_2017                                      :integer          default(0), not null
#  needs_help_2018                                      :integer          default(0), not null
#  needs_help_2019                                      :integer          default(0), not null
#  needs_help_2020                                      :integer          default(0), not null
#  needs_help_2021                                      :integer          default(0), not null
#  needs_to_flush_searchable_data_set_at                :datetime
#  no_eligibility_checks_apply                          :integer          default(0), not null
#  no_ssn                                               :integer          default(0), not null
#  other_income_types                                   :string
#  paid_alimony                                         :integer          default(0), not null
#  paid_charitable_contributions                        :integer          default(0), not null
#  paid_dependent_care                                  :integer          default(0), not null
#  paid_local_tax                                       :integer          default(0), not null
#  paid_medical_expenses                                :integer          default(0), not null
#  paid_mortgage_interest                               :integer          default(0), not null
#  paid_retirement_contributions                        :integer          default(0), not null
#  paid_school_supplies                                 :integer          default(0), not null
#  paid_student_loan_interest                           :integer          default(0), not null
#  phone_number                                         :string
#  phone_number_can_receive_texts                       :integer          default(0), not null
#  preferred_interview_language                         :string
#  preferred_name                                       :string
#  preferred_written_language                           :string
#  primary_active_armed_forces                          :integer          default("unfilled"), not null
#  primary_birth_date                                   :date
#  primary_consented_to_service                         :integer          default("unfilled"), not null
#  primary_consented_to_service_at                      :datetime
#  primary_consented_to_service_ip                      :inet
#  primary_first_name                                   :string
#  primary_last_name                                    :string
#  primary_middle_initial                               :string
#  primary_prior_year_agi_amount                        :integer
#  primary_prior_year_signature_pin                     :string
#  primary_signature_pin_at                             :datetime
#  primary_suffix                                       :string
#  primary_tin_type                                     :integer
#  received_advance_ctc_payment                         :integer
#  received_alimony                                     :integer          default(0), not null
#  received_homebuyer_credit                            :integer          default(0), not null
#  received_irs_letter                                  :integer          default(0), not null
#  received_stimulus_payment                            :integer          default(0), not null
#  referrer                                             :string
#  refund_payment_method                                :integer          default("unfilled"), not null
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
#  spouse_can_be_claimed_as_dependent                   :integer          default("unfilled")
#  spouse_consented_to_service                          :integer          default(0), not null
#  spouse_consented_to_service_at                       :datetime
#  spouse_consented_to_service_ip                       :inet
#  spouse_email_address                                 :citext
#  spouse_filed_prior_tax_year                          :integer          default("unfilled"), not null
#  spouse_first_name                                    :string
#  spouse_had_disability                                :integer          default(0), not null
#  spouse_issued_identity_pin                           :integer          default(0), not null
#  spouse_last_name                                     :string
#  spouse_middle_initial                                :string
#  spouse_prior_year_agi_amount                         :integer
#  spouse_prior_year_signature_pin                      :string
#  spouse_signature_pin_at                              :datetime
#  spouse_suffix                                        :string
#  spouse_tin_type                                      :integer
#  spouse_was_blind                                     :integer          default(0), not null
#  spouse_was_full_time_student                         :integer          default(0), not null
#  spouse_was_on_visa                                   :integer          default(0), not null
#  state                                                :string
#  state_of_residence                                   :string
#  street_address                                       :string
#  street_address2                                      :string
#  timezone                                             :string
#  type                                                 :string
#  use_primary_name_for_name_control                    :boolean          default(FALSE)
#  used_itin_certifying_acceptance_agent                :boolean          default(FALSE), not null
#  viewed_at_capacity                                   :boolean          default(FALSE)
#  vita_partner_name                                    :string
#  wants_to_itemize                                     :integer          default(0), not null
#  was_blind                                            :integer          default(0), not null
#  was_full_time_student                                :integer          default(0), not null
#  was_on_visa                                          :integer          default(0), not null
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
#  index_intakes_on_needs_to_flush_searchable_data_set_at  (needs_to_flush_searchable_data_set_at) WHERE (needs_to_flush_searchable_data_set_at IS NOT NULL)
#  index_intakes_on_phone_number                           (phone_number)
#  index_intakes_on_searchable_data                        (searchable_data) USING gin
#  index_intakes_on_sms_phone_number                       (sms_phone_number)
#  index_intakes_on_spouse_email_address                   (spouse_email_address)
#  index_intakes_on_type                                   (type)
#  index_intakes_on_vita_partner_id                        (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
class Intake::CtcIntake < Intake
  attribute :eip1_amount_received, :money
  attribute :eip2_amount_received, :money
  attribute :primary_prior_year_agi_amount, :money
  attribute :spouse_prior_year_agi_amount, :money

  attr_encrypted :primary_ssn, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }
  attr_encrypted :spouse_ssn, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }
  attr_encrypted :primary_ip_pin, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }
  attr_encrypted :spouse_ip_pin, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }
  attr_encrypted :primary_signature_pin, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }
  attr_encrypted :spouse_signature_pin, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }

  enum had_dependents: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_dependents
  enum eip1_entry_method: { unfilled: 0, calculated_amount: 1, did_not_receive: 2, manual_entry: 3 }, _prefix: :eip1_entry_method
  enum eip2_entry_method: { unfilled: 0, calculated_amount: 1, did_not_receive: 2, manual_entry: 3 }, _prefix: :eip2_entry_method
  enum eip1_and_2_amount_received_confidence: { unfilled: 0, sure: 1, unsure: 2 }, _prefix: :eip1_and_2_amount_received_confidence
  enum filed_prior_tax_year: { unfilled: 0, filed_full: 1, filed_non_filer: 2, did_not_file: 3 }, _prefix: :filed_prior_tax_year
  enum spouse_filed_prior_tax_year: { unfilled: 0, filed_full_joint: 1, filed_non_filer_joint: 2, filed_full_separate: 3, filed_non_filer_separate: 4, did_not_file: 5 }, _prefix: :spouse_filed_prior_tax_year
  enum had_reportable_income: { yes: 1, no: 2 }, _prefix: :had_reportable_income
  enum spouse_can_be_claimed_as_dependent: { unfilled: 0, yes: 1, no: 2 }, _prefix: :spouse_can_be_claimed_as_dependent
  enum spouse_active_armed_forces: { unfilled: 0, yes: 1, no: 2 }, _prefix: :spouse_active_armed_forces
  enum cannot_claim_me_as_a_dependent: { unfilled: 0, yes: 1, no: 2 }, _prefix: :cannot_claim_me_as_a_dependent
  enum primary_active_armed_forces: { unfilled: 0, yes: 1, no: 2 }, _prefix: :primary_active_armed_forces
  enum has_primary_ip_pin: { unfilled: 0, yes: 1, no: 2 }, _prefix: :has_primary_ip_pin
  enum has_spouse_ip_pin: { unfilled: 0, yes: 1, no: 2 }, _prefix: :has_spouse_ip_pin
  enum consented_to_legal: { unfilled: 0, yes: 1, no: 2 }, _prefix: :consented_to_legal
  scope :accessible_intakes, -> do
    sms_verified = where.not(sms_phone_number_verified_at: nil)
    email_verified = where.not(email_address_verified_at: nil)
    navigator_verified = where.not(navigator_has_verified_client_identity: nil)
    sms_verified.or(email_verified).or(navigator_verified)
  end
  has_one :bank_account, inverse_of: :intake, foreign_key: :intake_id, dependent: :destroy
  accepts_nested_attributes_for :bank_account

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

  def duplicates
    if email_address.present? && sms_phone_number.present?
      DeduplificationService.duplicates(self, :email_address, from_scope: self.class.accessible_intakes)
          .or(DeduplificationService.duplicates(self, :sms_phone_number, from_scope: self.class.accessible_intakes))
    elsif email_address.present?
      DeduplificationService.duplicates(self, :email_address, from_scope: self.class.accessible_intakes)
    elsif sms_phone_number.present?
      DeduplificationService.duplicates(self, :sms_phone_number, from_scope: self.class.accessible_intakes)
    else
      self.class.none
    end
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
    tax_returns.find_by(year: TaxReturn.current_tax_year)
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
end
