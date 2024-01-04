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
class StateFileAzIntake < StateFileBaseIntake
  encrypts :account_number, :routing_number, :raw_direct_file_data

  enum has_prior_last_names: { unfilled: 0, yes: 1, no: 2 }, _prefix: :has_prior_last_names
  enum was_incarcerated: { unfilled: 0, yes: 1, no: 2 }, _prefix: :was_incarcerated
  enum tribal_member: { unfilled: 0, yes: 1, no: 2 }, _prefix: :tribal_member
  enum armed_forces_member: { unfilled: 0, yes: 1, no: 2 }, _prefix: :armed_forces_member
  enum charitable_contributions: { unfilled: 0, yes: 1, no: 2 }, _prefix: :charitable_contributions
  enum eligibility_married_filing_separately: { unfilled: 0, yes: 1, no: 2 }, _prefix: :eligibility_married_filing_separately
  enum eligibility_529_for_non_qual_expense: { unfilled: 0, yes: 1, no: 2 }, _prefix: :eligibility_529_for_non_qual_expense

  before_save do
    save_nil_enums_with_unfilled

    if payment_or_deposit_type_changed?(to: "mail") || payment_or_deposit_type_changed?(to: "unfilled")
      self.account_type = "unfilled"
      self.bank_name = nil
      self.routing_number = nil
      self.account_number = nil
      self.withdraw_amount = nil
      self.date_electronic_withdrawal = nil
    end
  end

  def state_code
    'az'
  end

  def state_name
    'Arizona'
  end

  def tax_calculator(include_source: false)
    Efile::Az::Az140.new(
      year: MultiTenantService.statefile.current_tax_year,
      intake: self,
      include_source: include_source
    )
  end

  def federal_dependent_count_under_17
    self.dependents.select{ |dependent| dependent.age < 17 }.length
  end

  def federal_dependent_count_over_17_non_senior
    self.dependents.select{ |dependent| dependent.age >= 17 && !dependent.ask_senior_questions? }.length
  end

  def qualifying_parents_and_grandparents
    self.dependents.select(&:ask_senior_questions?).length
  end

  def ask_months_in_home?
    true
  end

  def ask_primary_dob?
    false
  end

  def ask_spouse_name?
    filing_status_mfj?
  end

  def ask_spouse_dob?
    false
  end

  def disqualifying_df_data_reason
    return :married_filing_separately if direct_file_data.filing_status == 3

    w2_states = direct_file_data.parsed_xml.css('W2StateLocalTaxGrp W2StateTaxGrp StateAbbreviationCd')
    :has_out_of_state_w2 if w2_states.any? do |state|
      (state.text || '').upcase != state_code.upcase
    end
  end

  def disqualifying_eligibility_rules
    {
      eligibility_lived_in_state: "no",
      eligibility_married_filing_separately: "yes",
      eligibility_out_of_state_income: "yes",
      eligibility_529_for_non_qual_expense: "yes",
    }
  end

  def ask_whether_incarcerated?
    has_valid_ssn = primary.ssn.present? && !primary.has_itin?
    has_valid_agi = direct_file_data.fed_agi <= (filing_status_mfj? || filing_status_hoh? ? 25_000 : 12_500)
    has_valid_ssn && has_valid_agi
  end
end
