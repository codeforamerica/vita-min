# == Schema Information
#
# Table name: intakes
#
#  id                                                   :bigint           not null, primary key
#  additional_info                                      :string
#  adopted_child                                        :integer          default("unfilled"), not null
#  already_filed                                        :integer          default("unfilled"), not null
#  anonymous                                            :boolean          default(FALSE), not null
#  balance_pay_from_bank                                :integer          default("unfilled"), not null
#  bank_account_type                                    :integer          default("unfilled"), not null
#  bought_energy_efficient_items                        :integer
#  bought_health_insurance                              :integer          default("unfilled"), not null
#  city                                                 :string
#  completed_intake_sent_to_zendesk                     :boolean
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
#  feeling_about_taxes                                  :integer          default("unfilled"), not null
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
#  had_student_in_family                                :integer          default("unfilled"), not null
#  had_tax_credit_disallowed                            :integer          default("unfilled"), not null
#  had_tips                                             :integer          default("unfilled"), not null
#  had_unemployment_income                              :integer          default("unfilled"), not null
#  had_wages                                            :integer          default("unfilled"), not null
#  income_over_limit                                    :integer          default("unfilled"), not null
#  intake_pdf_sent_to_zendesk                           :boolean          default(FALSE), not null
#  interview_timing_preference                          :string
#  issued_identity_pin                                  :integer          default("unfilled"), not null
#  job_count                                            :integer
#  lived_with_spouse                                    :integer          default("unfilled"), not null
#  made_estimated_tax_payments                          :integer          default("unfilled"), not null
#  married                                              :integer          default("unfilled"), not null
#  multiple_states                                      :integer          default("unfilled"), not null
#  needs_help_2016                                      :integer          default("unfilled"), not null
#  needs_help_2017                                      :integer          default("unfilled"), not null
#  needs_help_2018                                      :integer          default("unfilled"), not null
#  needs_help_2019                                      :integer          default("unfilled"), not null
#  no_eligibility_checks_apply                          :integer          default("unfilled"), not null
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
#  savings_purchase_bond                                :integer          default("unfilled"), not null
#  savings_split_refund                                 :integer          default("unfilled"), not null
#  separated                                            :integer          default("unfilled"), not null
#  separated_year                                       :string
#  sms_notification_opt_in                              :integer          default("unfilled"), not null
#  sms_phone_number                                     :string
#  sold_a_home                                          :integer          default("unfilled"), not null
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
#  intake_ticket_id                                     :bigint
#  intake_ticket_requester_id                           :bigint
#  visitor_id                                           :string
#  vita_partner_id                                      :bigint
#  zendesk_group_id                                     :string
#
# Indexes
#
#  index_intakes_on_vita_partner_id  (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#

class Intake < ApplicationRecord
  # TODO: remove users association
  has_many :users # order doesn't really matter at the moment
  has_many :documents, -> { order(created_at: :asc) }
  has_many :dependents, -> { order(created_at: :asc) }
  has_many :ticket_statuses, -> { order(created_at: :asc) }
  belongs_to :vita_partner, optional: true

  attr_encrypted :primary_last_four_ssn, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }
  attr_encrypted :spouse_last_four_ssn, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }
  attr_encrypted :bank_name, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }
  attr_encrypted :bank_routing_number, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }
  attr_encrypted :bank_account_number, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }

  enum adopted_child: { unfilled: 0, yes: 1, no: 2 }, _prefix: :adopted_child
  enum already_filed: { unfilled: 0, yes: 1, no: 2 }, _prefix: :already_filed
  enum bought_energy_efficient_items: { unfilled: 0, yes: 1, no: 2 }, _prefix: :bought_energy_efficient_items
  enum bought_health_insurance: { unfilled: 0, yes: 1, no: 2 }, _prefix: :bought_health_insurance
  enum balance_pay_from_bank: { unfilled: 0, yes: 1, no: 2 }, _prefix: :balance_pay_from_bank
  enum bank_account_type: { unfilled: 0, checking: 1, savings: 2, unspecified: 3 }, _prefix: :bank_account_type
  enum demographic_questions_opt_in: { unfilled: 0, yes: 1, no: 2 }, _prefix: :demographic_questions_opt_in
  enum demographic_english_conversation: { unfilled: 0, very_well: 1, well: 2 , not_well: 3, not_at_all: 4, prefer_not_to_answer: 5}, _prefix: :demographic_english_conversation
  enum demographic_english_reading: { unfilled: 0, very_well: 1, well: 2 , not_well: 3, not_at_all: 4, prefer_not_to_answer: 5}, _prefix: :demographic_english_reading
  enum demographic_disability: { unfilled: 0, yes: 1, no: 2, prefer_not_to_answer: 3 }, _prefix: :demographic_disability
  enum demographic_veteran: { unfilled: 0, yes: 1, no: 2, prefer_not_to_answer: 3 }, _prefix: :demographic_veteran
  enum demographic_primary_ethnicity: { unfilled: 0, hispanic_latino: 1, not_hispanic_latino: 2, prefer_not_to_answer: 3 }, _prefix: :demographic_primary_ethnicity
  enum demographic_spouse_ethnicity: { unfilled: 0, hispanic_latino: 1, not_hispanic_latino: 2, prefer_not_to_answer: 3 }, _prefix: :demographic_spouse_ethnicity
  enum divorced: { unfilled: 0, yes: 1, no: 2 }, _prefix: :divorced
  enum email_notification_opt_in: { unfilled: 0, yes: 1, no: 2 }, _prefix: :email_notification_opt_in
  enum ever_married: { unfilled: 0, yes: 1, no: 2 }, _prefix: :ever_married
  enum feeling_about_taxes: { unfilled: 0, positive: 1, neutral: 2, negative: 3 }, _prefix: :feeling_about_taxes
  enum filing_joint: { unfilled: 0, yes: 1, no: 2 }, _prefix: :filing_joint
  enum had_asset_sale_income: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_asset_sale_income
  enum had_debt_forgiven: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_debt_forgiven
  enum had_dependents: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_dependents
  enum had_disability: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_disability
  enum had_disability_income: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_disability_income
  enum had_disaster_loss: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_disaster_loss
  enum had_farm_income: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_farm_income
  enum had_gambling_income: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_gambling_income
  enum had_hsa: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_hsa
  enum had_interest_income: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_interest_income
  enum had_local_tax_refund: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_local_tax_refund
  enum had_other_income: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_other_income
  enum had_rental_income: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_rental_income
  enum had_retirement_income: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_retirement_income
  enum had_self_employment_income: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_self_employment_income
  enum had_social_security_income: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_social_security_income
  enum had_student_in_family: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_student_in_family
  enum had_tax_credit_disallowed: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_tax_credit_disallowed
  enum had_tips: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_tips
  enum had_unemployment_income: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_unemployment_income
  enum had_wages: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_wages
  enum income_over_limit: { unfilled: 0, yes: 1, no: 2 }, _prefix: :income_over_limit
  enum issued_identity_pin: { unfilled: 0, yes: 1, no: 2 }, _prefix: :issued_identity_pin
  enum lived_with_spouse: { unfilled: 0, yes: 1, no: 2 }, _prefix: :lived_with_spouse
  enum made_estimated_tax_payments: { unfilled: 0, yes: 1, no: 2 }, _prefix: :made_estimated_tax_payments
  enum married: { unfilled: 0, yes: 1, no: 2 }, _prefix: :married
  enum multiple_states: { unfilled: 0, yes: 1, no: 2 }, _prefix: :multiple_states
  enum no_eligibility_checks_apply: { unfilled: 0, yes: 1, no: 2 }, _prefix: :no_eligibility_checks_apply
  enum needs_help_2016: { unfilled: 0, yes: 1, no: 2 }, _prefix: :needs_help_2016
  enum needs_help_2017: { unfilled: 0, yes: 1, no: 2 }, _prefix: :needs_help_2017
  enum needs_help_2018: { unfilled: 0, yes: 1, no: 2 }, _prefix: :needs_help_2018
  enum needs_help_2019: { unfilled: 0, yes: 1, no: 2 }, _prefix: :needs_help_2019
  enum paid_alimony: { unfilled: 0, yes: 1, no: 2 }, _prefix: :paid_alimony
  enum paid_charitable_contributions: { unfilled: 0, yes: 1, no: 2 }, _prefix: :paid_charitable_contributions
  enum paid_dependent_care: { unfilled: 0, yes: 1, no: 2 }, _prefix: :paid_dependent_care
  enum paid_local_tax: { unfilled: 0, yes: 1, no: 2 }, _prefix: :paid_local_tax
  enum paid_medical_expenses: { unfilled: 0, yes: 1, no: 2 }, _prefix: :paid_medical_expenses
  enum paid_mortgage_interest: { unfilled: 0, yes: 1, no: 2 }, _prefix: :paid_mortgage_interest
  enum paid_retirement_contributions: { unfilled: 0, yes: 1, no: 2 }, _prefix: :paid_retirement_contributions
  enum paid_school_supplies: { unfilled: 0, yes: 1, no: 2 }, _prefix: :paid_school_supplies
  enum paid_student_loan_interest: { unfilled: 0, yes: 1, no: 2 }, _prefix: :paid_student_loan_interest
  enum phone_number_can_receive_texts: { unfilled: 0, yes: 1, no: 2 }, _prefix: :phone_number_can_receive_texts
  enum primary_consented_to_service: { unfilled: 0, yes: 1, no: 2 }, _prefix: :primary_consented_to_service
  enum received_alimony: { unfilled: 0, yes: 1, no: 2 }, _prefix: :received_alimony
  enum received_homebuyer_credit: { unfilled: 0, yes: 1, no: 2 }, _prefix: :received_homebuyer_credit
  enum received_irs_letter: { unfilled: 0, yes: 1, no: 2 }, _prefix: :received_irs_letter
  enum refund_payment_method: { unfilled: 0, direct_deposit: 1, check: 2 }, _prefix: :refund_payment_method
  enum reported_asset_sale_loss: { unfilled: 0, yes: 1, no: 2 }, _prefix: :reported_asset_sale_loss
  enum reported_self_employment_loss: { unfilled: 0, yes: 1, no: 2 }, _prefix: :reported_self_employment_loss
  enum savings_split_refund: { unfilled: 0, yes: 1, no: 2 }, _prefix: :savings_split_refund
  enum savings_purchase_bond: { unfilled: 0, yes: 1, no: 2 }, _prefix: :savings_purchase_bond
  enum separated: { unfilled: 0, yes: 1, no: 2 }, _prefix: :separated
  enum sms_notification_opt_in: { unfilled: 0, yes: 1, no: 2 }, _prefix: :sms_notification_opt_in
  enum spouse_consented_to_service: { unfilled: 0, yes: 1, no: 2 }, _prefix: :spouse_consented_to_service
  enum spouse_was_full_time_student: { unfilled: 0, yes: 1, no: 2 }, _prefix: :spouse_was_full_time_student
  enum spouse_was_on_visa: { unfilled: 0, yes: 1, no: 2 }, _prefix: :spouse_was_on_visa
  enum spouse_had_disability: { unfilled: 0, yes: 1, no: 2 }, _prefix: :spouse_had_disability
  enum spouse_was_blind: { unfilled: 0, yes: 1, no: 2 }, _prefix: :spouse_was_blind
  enum spouse_issued_identity_pin: { unfilled: 0, yes: 1, no: 2 }, _prefix: :spouse_issued_identity_pin
  enum sold_a_home: { unfilled: 0, yes: 1, no: 2 }, _prefix: :sold_a_home
  enum was_blind: { unfilled: 0, yes: 1, no: 2 }, _prefix: :was_blind
  enum was_full_time_student: { unfilled: 0, yes: 1, no: 2 }, _prefix: :was_full_time_student
  enum was_on_visa: { unfilled: 0, yes: 1, no: 2 }, _prefix: :was_on_visa
  enum widowed: { unfilled: 0, yes: 1, no: 2 }, _prefix: :widowed

  scope :anonymous, -> {where(anonymous: true)}

  def self.create_anonymous_intake(original_intake)
    Intake.create(
      intake_ticket_id: original_intake.intake_ticket_id,
      visitor_id: original_intake.visitor_id,
      anonymous: true
    )
  end

  def self.find_original_intake(anonymous_intake)
    Intake
      .where(intake_ticket_id: anonymous_intake.intake_ticket_id, anonymous: false)
      .order(created_at: :asc)
      .first
  end

  def self.find_for_requested_docs_token(token)
    Intake
      .where.not(requested_docs_token: nil)
      .where(requested_docs_token: token, anonymous: false)
      .first
  end

  # Returns the phone number formatted for user display, e.g.: "(510) 555-1234"
  def formatted_phone_number
    Phonelib.parse(phone_number).local_number
  end

  # Returns the phone number in the E164 standardized format, e.g.: "+15105551234"
  def standardized_phone_number
    Phonelib.parse(phone_number, "US").e164
  end

  def primary_full_name
    "#{primary_first_name} #{primary_last_name}"
  end

  def spouse_full_name
    "#{spouse_first_name} #{spouse_last_name}"
  end

  def primary_user
    users.where.not(is_spouse: true).first
  end

  def spouse
    users.where(is_spouse: true).first
  end

  def pdf
    IntakePdf.new(self).output_file
  end

  def consent_pdf
    ConsentPdf.new(self).output_file
  end

  def bank_details_png
    BankDetailsPdf.new(self).as_png
  end

  def referrer_domain
    URI.parse(referrer).host if referrer.present?
  end

  def state_of_residence_name
    States.name_for_key(state_of_residence)
  end

  def tax_year
    2019
  end

  def had_a_job?
    job_count.present? && job_count > 0
  end

  def eligible_for_vita?
    # if any are unfilled this will return false
    had_farm_income_no? && had_rental_income_no? && income_over_limit_no?
  end

  def any_students?
    was_full_time_student_yes? ||
      spouse_was_full_time_student_yes? ||
      had_student_in_family_yes? ||
      dependents.where(was_student: "yes").any?
  end

  def spouse_name_or_placeholder
    return "Your spouse" unless spouse_first_name.present?
    spouse_full_name
  end

  def student_names
    names = []
    names << primary_full_name if was_full_time_student_yes?
    names << spouse_name_or_placeholder if spouse_was_full_time_student_yes?
    names += dependents.where(was_student: "yes").map(&:full_name)
    names
  end

  def external_id
    return unless id.present?

    ["intake", id].join("-")
  end

  def get_or_create_spouse_auth_token
    return spouse_auth_token if spouse_auth_token.present?

    new_token = SecureRandom.urlsafe_base64(8)
    update(spouse_auth_token: new_token)
    new_token
  end

  def get_or_create_requested_docs_token
    return requested_docs_token if requested_docs_token.present?

    new_token = SecureRandom.urlsafe_base64(10)
    update(requested_docs_token: new_token, requested_docs_token_created_at: Time.now)
    new_token
  end

  def requested_docs_token_link
    "#{Rails.application.routes.url_helpers.root_url}documents/add/#{get_or_create_requested_docs_token}"
  end

  def mixpanel_data
    return Intake.find_original_intake(self).mixpanel_data if anonymous

    dependents_under_6 = dependents.any? { |dependent| dependent.age_at_end_of_tax_year < 6 }
    had_earned_income = had_a_job? || had_wages_yes? || had_self_employment_income_yes?
    {
      intake_source: source,
      intake_referrer: referrer,
      intake_referrer_domain: referrer_domain,
      primary_filer_age_at_end_of_tax_year: age_end_of_tax_year.to_s,
      spouse_age_at_end_of_tax_year: spouse_age_end_of_tax_year.to_s,
      primary_filer_disabled: had_disability,
      spouse_disabled: spouse_had_disability,
      had_dependents: dependents.size > 0 ? "yes" : "no",
      number_of_dependents: dependents.size.to_s,
      had_dependents_under_6: dependents_under_6 ? "yes" : "no",
      filing_joint: filing_joint,
      had_earned_income: had_earned_income ? "yes" : "no",
      state: state,
      zip_code: zip_code,
      needs_help_2019: needs_help_2019,
      needs_help_2018: needs_help_2018,
      needs_help_2017: needs_help_2017,
      needs_help_2016: needs_help_2016,
      needs_help_backtaxes: (needs_help_2018_yes? || needs_help_2017_yes? || needs_help_2016_yes?) ? "yes" : "no",
      zendesk_instance_domain: zendesk_instance_domain,
      zendesk_group_id: zendesk_group_id,
      vita_partner_name: vita_partner_name,
    }
  end

  def filing_years
    [
      ("2019" if needs_help_2019_yes?),
      ("2018" if needs_help_2018_yes?),
      ("2017" if needs_help_2017_yes?),
      ("2016" if needs_help_2016_yes?),
    ].compact
  end

  def most_recent_filing_year
    filing_years.first
  end

  def include_bank_details?
    refund_payment_method_direct_deposit? || balance_pay_from_bank_yes?
  end

  def year_before_most_recent_filing_year
    (most_recent_filing_year.to_i - 1).to_s if most_recent_filing_year.present?
  end

  def assign_vita_partner!
    # this should only be called before get_or_create_zendesk_group_id has ever been called
    # because we want users to be able to change which group they are routed to up until the ZD ticket has been created,
    # we don't call get_or_create_zendesk_group_id, we only check whether it has been persisted, and do not save it
    group_id = zendesk_group_id || determine_zendesk_group_id
    if group_id
      partner = VitaPartner.find_by(zendesk_group_id: group_id)
      raise "unable to determine VITA Partner from zendesk group id: [#{group_id}]" unless partner.present?
      update(vita_partner_id: partner.id, vita_partner_name: partner.name)
    end
  end

  def get_or_create_zendesk_group_id
    return zendesk_group_id if zendesk_group_id.present?

    group_id = determine_zendesk_group_id
    self.update(zendesk_group_id: group_id)
    group_id
  end

  def determine_zendesk_group_id
    # TODO: this should be refactored into a business logic / referral component
    # (or removed entirely once all UW/TSA Zendesk tickets have been closed)
    return nil if zendesk_instance == UwtsaZendeskInstance
    if source.present? && group_id_for_source.present?
      group_id_for_source
    else
      group_id_for_state
    end
  end

  def zendesk_instance
    if get_or_create_zendesk_instance_domain == EitcZendeskInstance::DOMAIN
      EitcZendeskInstance
    else
      UwtsaZendeskInstance
    end
  end

  def contact_info_filtered_by_preferences
    contact_info = {}
    contact_info[:phone_number] = standardized_phone_number if sms_notification_opt_in_yes?
    contact_info[:email] = email_address if email_notification_opt_in_yes?
    contact_info
  end

  def opted_into_notifications?
    sms_notification_opt_in_yes? || email_notification_opt_in_yes?
  end

  def age_end_of_tax_year
    return unless primary_birth_date.present?

    tax_year - primary_birth_date.year
  end

  def spouse_age_end_of_tax_year
    return unless spouse_birth_date.present?

    tax_year - spouse_birth_date.year
  end

  def get_or_create_zendesk_instance_domain
    return zendesk_instance_domain if zendesk_instance_domain.present?

    domain = determine_zendesk_instance_domain
    self.update(zendesk_instance_domain: domain)
    domain
  end

  def determine_zendesk_instance_domain
    EitcZendeskInstance::DOMAIN
  end

  def current_ticket_status
    # we think this is faster than doing ticket_statuses.last
    ticket_statuses.reorder(created_at: :desc).first
  end

  private

  def group_id_for_source
    EitcZendeskInstance::ORGANIZATION_SOURCE_PARAMETERS.each do |key, value|
      if source.downcase.starts_with?(key.to_s)
        return value
      end
    end
    nil
  end

  def group_id_for_state
    EitcZendeskInstance::GROUP_ID_TO_STATE_LIST_MAPPING.each do |group_id, state_list|
      return group_id if state_list.include? state_of_residence
    end

    EitcZendeskInstance::ONLINE_INTAKE_UW_TSA
  end
end
