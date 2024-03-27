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
#  df_data_import_failed_at              :datetime
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
#  household_excise_credit_claimed       :integer          default("unfilled"), not null
#  last_completed_step                   :string
#  last_sign_in_at                       :datetime
#  last_sign_in_ip                       :inet
#  locale                                :string           default("en")
#  locked_at                             :datetime
#  message_tracker                       :jsonb
#  payment_or_deposit_type               :integer          default("unfilled"), not null
#  phone_number                          :string
#  phone_number_verified_at              :datetime
#  primary_birth_date                    :date
#  primary_esigned                       :integer          default("unfilled"), not null
#  primary_esigned_at                    :datetime
#  primary_first_name                    :string
#  primary_last_name                     :string
#  primary_middle_initial                :string
#  primary_suffix                        :string
#  prior_last_names                      :string
#  raw_direct_file_data                  :text
#  referrer                              :string
#  routing_number                        :string
#  sign_in_count                         :integer          default(0), not null
#  source                                :string
#  spouse_birth_date                     :date
#  spouse_esigned                        :integer          default("unfilled"), not null
#  spouse_esigned_at                     :datetime
#  spouse_first_name                     :string
#  spouse_last_name                      :string
#  spouse_middle_initial                 :string
#  spouse_suffix                         :string
#  ssn_no_employment                     :integer          default("unfilled"), not null
#  tribal_member                         :integer          default("unfilled"), not null
#  tribal_wages                          :integer
#  unfinished_intake_ids                 :text             default([]), is an Array
#  unsubscribed_from_email               :boolean          default(FALSE), not null
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
  STATE_CODE = 'az'.freeze
  STATE_NAME = 'Arizona'.freeze
  STATE_CODE_AND_NAME = {
    STATE_CODE => STATE_NAME
  }.freeze

  encrypts :account_number, :routing_number, :raw_direct_file_data

  enum has_prior_last_names: { unfilled: 0, yes: 1, no: 2 }, _prefix: :has_prior_last_names
  enum was_incarcerated: { unfilled: 0, yes: 1, no: 2 }, _prefix: :was_incarcerated
  enum ssn_no_employment: { unfilled: 0, yes: 1, no: 2 }, _prefix: :ssn_no_employment
  enum household_excise_credit_claimed: { unfilled: 0, yes: 1, no: 2 }, _prefix: :household_excise_credit_claimed
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
    STATE_CODE
  end

  def state_name
    STATE_NAME
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

  def federal_dependent_count_over_17_non_qualifying_senior
    self.dependents.select{ |dependent| dependent.age >= 17 && !dependent.is_qualifying_parent_or_grandparent? }.length
  end

  def qualifying_parents_and_grandparents
    self.dependents.select(&:is_qualifying_parent_or_grandparent?).length
  end

  def ask_months_in_home?
    true
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

  def qualified_for_excise_credit?
    was_incarcerated_no? && ssn_no_employment_no? && household_excise_credit_claimed_no?
  end

  def filing_status
    return :head_of_household if direct_file_data&.filing_status == 5 # Treat qualifying_widow as hoh
    super
  end

  def total_subtractions
    lines = [:AZ140_LINE_20, :AZ140_LINE_21, :AZ140_LINE_22, :AZ140_LINE_23, :AZ140_LINE_24, :AZ140_LINE_25,
             :AZ140_LINE_26, :AZ140_LINE_27, :AZ140_LINE_28, :AZ140_LINE_29, :AZ140_LINE_30, :AZ140_LINE_31,
             :AZ140_LINE_32, :AZ140_LINE_33, :AZ140_LINE_34]
    subtractions = 0
    lines.each { |line| subtractions += self.calculator.line_or_zero(line) }
    subtractions
  end

  def total_exemptions
    lines = [:AZ140_LINE_38, :AZ140_LINE_39, :AZ140_LINE_40, :AZ140_LINE_41]
    exemptions = 0
    lines.each { |line| exemptions += self.calculator.line_or_zero(line) }
    exemptions
  end

  def requires_hoh_qualifying_person_name?
    filing_status == :head_of_household
  end

  def hoh_qualifying_person_name
    return unless requires_hoh_qualifying_person_name?

    if direct_file_data&.hoh_qualifying_person_name.present?
      # Federal data is an unstructured string - split on first space and everything in the second group goes to last name
      names = direct_file_data.hoh_qualifying_person_name.split(/ /, 2)
      return {
        :first_name => names[0],
        :last_name => names[1]
      }
    end

    # This is fallback logic in case the data is not given in the federal return
    hoh_qualifying_dependents = self.dependents.select(&:is_hoh_qualifying_person?)
    unless hoh_qualifying_dependents.empty?
      six_plus_months_in_home = hoh_qualifying_dependents.reject { |dependent|
        dependent[:months_in_home] < 6
      }
      hoh_qualifying_dependent = six_plus_months_in_home.max_by { |dependent|
        [dependent[:months_in_home], -dependent.age]
      }
      if hoh_qualifying_dependent.nil?
        hoh_qualifying_dependent = hoh_qualifying_dependents.select { |dependent|
          dependent[:relationship] == "PARENT"
        }.max_by(&:age)
      end
      {
        :first_name => hoh_qualifying_dependent.first_name,
        :last_name => hoh_qualifying_dependent.last_name
      }
    end
  end
end
