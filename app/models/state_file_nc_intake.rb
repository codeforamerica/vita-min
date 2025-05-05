# == Schema Information
#
# Table name: state_file_nc_intakes
#
#  id                                :bigint           not null, primary key
#  account_number                    :string
#  account_type                      :integer          default("unfilled"), not null
#  city                              :string
#  consented_to_sms_terms            :integer          default("unfilled"), not null
#  consented_to_terms_and_conditions :integer          default("unfilled"), not null
#  contact_preference                :integer          default("unfilled"), not null
#  county_during_hurricane_helene    :string
#  current_sign_in_at                :datetime
#  current_sign_in_ip                :inet
#  current_step                      :string
#  date_electronic_withdrawal        :date
#  df_data_import_succeeded_at       :datetime
#  df_data_imported_at               :datetime
#  eligibility_ed_loan_cancelled     :integer          default("no"), not null
#  eligibility_ed_loan_emp_payment   :integer          default("no"), not null
#  eligibility_lived_in_state        :integer          default("unfilled"), not null
#  eligibility_out_of_state_income   :integer          default("unfilled"), not null
#  eligibility_withdrew_529          :integer          default("unfilled"), not null
#  email_address                     :citext
#  email_address_verified_at         :datetime
#  email_notification_opt_in         :integer          default("unfilled"), not null
#  extension_payments_amount         :decimal(12, 2)
#  failed_attempts                   :integer          default(0), not null
#  federal_return_status             :string
#  hashed_ssn                        :string
#  last_sign_in_at                   :datetime
#  last_sign_in_ip                   :inet
#  locale                            :string           default("en")
#  locked_at                         :datetime
#  message_tracker                   :jsonb
#  moved_after_hurricane_helene      :integer          default("unfilled"), not null
#  out_of_country                    :integer          default("unfilled"), not null
#  paid_extension_payments           :integer          default("unfilled"), not null
#  paid_federal_extension_payments   :integer          default("unfilled"), not null
#  payment_or_deposit_type           :integer          default("unfilled"), not null
#  phone_number                      :string
#  phone_number_verified_at          :datetime
#  primary_birth_date                :date
#  primary_esigned                   :integer          default("unfilled"), not null
#  primary_esigned_at                :datetime
#  primary_first_name                :string
#  primary_last_name                 :string
#  primary_middle_initial            :string
#  primary_suffix                    :string
#  primary_veteran                   :integer          default("unfilled"), not null
#  raw_direct_file_data              :text
#  raw_direct_file_intake_data       :jsonb
#  referrer                          :string
#  residence_county                  :string
#  routing_number                    :string
#  sales_use_tax                     :decimal(12, 2)
#  sales_use_tax_calculation_method  :integer          default("unfilled"), not null
#  sign_in_count                     :integer          default(0), not null
#  sms_notification_opt_in           :integer          default("unfilled"), not null
#  source                            :string
#  spouse_birth_date                 :date
#  spouse_death_year                 :integer
#  spouse_esigned                    :integer          default("unfilled"), not null
#  spouse_esigned_at                 :datetime
#  spouse_first_name                 :string
#  spouse_last_name                  :string
#  spouse_middle_initial             :string
#  spouse_suffix                     :string
#  spouse_veteran                    :integer          default("unfilled"), not null
#  ssn                               :string
#  street_address                    :string
#  tribal_member                     :integer          default("unfilled"), not null
#  tribal_wages_amount               :decimal(12, 2)
#  unfinished_intake_ids             :text             default([]), is an Array
#  unsubscribed_from_email           :boolean          default(FALSE), not null
#  untaxed_out_of_state_purchases    :integer          default("unfilled"), not null
#  withdraw_amount                   :integer
#  zip_code                          :string
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  federal_submission_id             :string
#  primary_state_id_id               :bigint
#  spouse_state_id_id                :bigint
#  visitor_id                        :string
#
# Indexes
#
#  index_state_file_nc_intakes_on_hashed_ssn           (hashed_ssn)
#  index_state_file_nc_intakes_on_primary_state_id_id  (primary_state_id_id)
#  index_state_file_nc_intakes_on_spouse_state_id_id   (spouse_state_id_id)
#
class StateFileNcIntake < StateFileBaseIntake
  include DateHelper
  include NcResidenceCountyConcern
  encrypts :account_number, :routing_number, :raw_direct_file_data, :raw_direct_file_intake_data

  enum primary_veteran: { unfilled: 0, yes: 1, no: 2 }, _prefix: :primary_veteran
  enum spouse_veteran: { unfilled: 0, yes: 1, no: 2 }, _prefix: :spouse_veteran
  enum sales_use_tax_calculation_method: { unfilled: 0, automated: 1, manual: 2 }, _prefix: :sales_use_tax_calculation_method
  enum untaxed_out_of_state_purchases: { unfilled: 0, yes: 1, no: 2 }, _prefix: :untaxed_out_of_state_purchases
  enum tribal_member: { unfilled: 0, yes: 1, no: 2 }, _prefix: :tribal_member
  enum moved_after_hurricane_helene: { unfilled: 0, yes: 1, no: 2 }, _prefix: :moved_after_hurricane_helene
  enum eligibility_withdrew_529: { unfilled: 0, yes: 1, no: 2 }, _prefix: :eligibility_withdrew_529
  enum eligibility_lived_in_state: { unfilled: 0, yes: 1, no: 2 }, _prefix: :eligibility_lived_in_state
  enum eligibility_out_of_state_income: { unfilled: 0, yes: 1, no: 2 }, _prefix: :eligibility_out_of_state_income
  enum eligibility_ed_loan_cancelled: { no: 0, yes: 1 }, _prefix: :eligibility_ed_loan_cancelled
  enum eligibility_ed_loan_emp_payment: { no: 0, yes: 1 }, _prefix: :eligibility_ed_loan_emp_payment
  enum paid_extension_payments: { unfilled: 0, yes: 1, no: 2 }, _prefix: :paid_extension_payments
  enum out_of_country: { unfilled: 0, yes: 1, no: 2 }, _prefix: :out_of_country
  enum paid_federal_extension_payments: { unfilled: 0, yes: 1, no: 2 }, _prefix: :paid_federal_extension_payments

  attr_accessor :nc_eligiblity_none
  before_save :sanitize_county_details

  def sanitize_county_details
    if NcResidenceCountyConcern.designated_hurricane_county?(residence_county)
      self.moved_after_hurricane_helene = "unfilled"
    end

    unless moved_after_hurricane_helene_yes?
      self.county_during_hurricane_helene = nil
    end
  end

  def calculate_sales_use_tax
    nc_taxable_income = calculator.lines[:NCD400_LINE_14].value
    calculator.calculate_use_tax(nc_taxable_income)
  end

  def disaster_relief_county
    disaster_relief_code = "#{residence_county_name}_Helene"
    designated_county_during_helene = NcResidenceCountyConcern.designated_hurricane_county?(county_during_hurricane_helene)

    if designated_county_during_helene && moved_after_hurricane_helene_yes?
      disaster_relief_code += ";#{COUNTIES[county_during_hurricane_helene]}_Helene"
    end

    disaster_relief_code
  end

  def disqualifying_df_data_reason
    w2_states = direct_file_data.parsed_xml.css('W2StateLocalTaxGrp W2StateTaxGrp StateAbbreviationCd')
    :has_out_of_state_w2 if w2_states.any? do |state|
      (state.text || '').upcase != state_code.upcase
    end
  end

  def disqualifying_eligibility_rules
    {
      eligibility_ed_loan_cancelled: "yes",
      eligibility_ed_loan_emp_payment: "yes"
    }
  end

  def show_tax_period_in_return_header?
    false
  end

  def requires_additional_withdrawal_information?
    true
  end

  def check_nra_status?
    true
  end

  def calculate_date_electronic_withdrawal(current_time:)
    submitted_before_deadline = StateFile::StateInformationService.before_payment_deadline?(2.business_days.after(current_time), self.state_code)
    if submitted_before_deadline
      date_electronic_withdrawal&.to_date
    else
      timezone = StateFile::StateInformationService.timezone(self.state_code)
      next_available_date(current_time.in_time_zone(timezone))
    end
  end

  def next_available_date(current_time)
    initial_days_to_add = after_business_hours(current_time) ? 2 : 1
    date = add_business_days_to_date(current_time, initial_days_to_add)
    date = add_business_days_to_date(date, 1) while holiday?(date)

    date.to_date
  end

  def positive_fed_agi?
    direct_file_data.fed_agi.positive?
  end
end
