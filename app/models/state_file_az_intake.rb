# == Schema Information
#
# Table name: state_file_az_intakes
#
#  id                                     :bigint           not null, primary key
#  account_number                         :string
#  account_type                           :integer
#  armed_forces_member                    :integer          default("unfilled"), not null
#  armed_forces_wages_amount              :decimal(12, 2)
#  bank_name                              :string
#  charitable_cash_amount                 :decimal(12, 2)
#  charitable_contributions               :integer          default("unfilled"), not null
#  charitable_noncash_amount              :decimal(12, 2)
#  consented_to_terms_and_conditions      :integer          default("unfilled"), not null
#  contact_preference                     :integer          default("unfilled"), not null
#  current_sign_in_at                     :datetime
#  current_sign_in_ip                     :inet
#  current_step                           :string
#  date_electronic_withdrawal             :date
#  df_data_import_succeeded_at            :datetime
#  df_data_imported_at                    :datetime
#  eligibility_529_for_non_qual_expense   :integer          default("unfilled"), not null
#  eligibility_lived_in_state             :integer          default("unfilled"), not null
#  eligibility_married_filing_separately  :integer          default("unfilled"), not null
#  eligibility_out_of_state_income        :integer          default("unfilled"), not null
#  email_address                          :citext
#  email_address_verified_at              :datetime
#  failed_attempts                        :integer          default(0), not null
#  federal_return_status                  :string
#  has_prior_last_names                   :integer          default("unfilled"), not null
#  hashed_ssn                             :string
#  household_excise_credit_claimed        :integer          default("unfilled"), not null
#  household_excise_credit_claimed_amount :decimal(12, 2)
#  last_sign_in_at                        :datetime
#  last_sign_in_ip                        :inet
#  locale                                 :string           default("en")
#  locked_at                              :datetime
#  made_az321_contributions               :integer          default("unfilled"), not null
#  message_tracker                        :jsonb
#  payment_or_deposit_type                :integer          default("unfilled"), not null
#  phone_number                           :string
#  phone_number_verified_at               :datetime
#  primary_birth_date                     :date
#  primary_esigned                        :integer          default("unfilled"), not null
#  primary_esigned_at                     :datetime
#  primary_first_name                     :string
#  primary_last_name                      :string
#  primary_middle_initial                 :string
#  primary_suffix                         :string
#  primary_was_incarcerated               :integer          default("unfilled"), not null
#  prior_last_names                       :string
#  raw_direct_file_data                   :text
#  raw_direct_file_intake_data            :jsonb
#  referrer                               :string
#  routing_number                         :string
#  sign_in_count                          :integer          default(0), not null
#  source                                 :string
#  spouse_birth_date                      :date
#  spouse_esigned                         :integer          default("unfilled"), not null
#  spouse_esigned_at                      :datetime
#  spouse_first_name                      :string
#  spouse_last_name                       :string
#  spouse_middle_initial                  :string
#  spouse_suffix                          :string
#  spouse_was_incarcerated                :integer          default("unfilled"), not null
#  ssn_no_employment                      :integer          default("unfilled"), not null
#  tribal_member                          :integer          default("unfilled"), not null
#  tribal_wages_amount                    :decimal(12, 2)
#  unfinished_intake_ids                  :text             default([]), is an Array
#  unsubscribed_from_email                :boolean          default(FALSE), not null
#  was_incarcerated                       :integer          default("unfilled"), not null
#  withdraw_amount                        :integer
#  created_at                             :datetime         not null
#  updated_at                             :datetime         not null
#  federal_submission_id                  :string
#  primary_state_id_id                    :bigint
#  spouse_state_id_id                     :bigint
#  visitor_id                             :string
#
# Indexes
#
#  index_state_file_az_intakes_on_email_address        (email_address)
#  index_state_file_az_intakes_on_hashed_ssn           (hashed_ssn)
#  index_state_file_az_intakes_on_primary_state_id_id  (primary_state_id_id)
#  index_state_file_az_intakes_on_spouse_state_id_id   (spouse_state_id_id)
#
class StateFileAzIntake < StateFileBaseIntake
  self.ignored_columns = %w[charitable_cash charitable_noncash household_excise_credit_claimed_amt tribal_wages armed_forces_wages]
  encrypts :account_number, :routing_number, :raw_direct_file_data, :raw_direct_file_intake_data

  has_many :az322_contributions, dependent: :destroy
  has_many :az321_contributions, dependent: :destroy
  enum has_prior_last_names: { unfilled: 0, yes: 1, no: 2 }, _prefix: :has_prior_last_names
  # TODO: decide what to do with was_incarcerated column; see if data science wants to keep the historic data
  enum was_incarcerated: { unfilled: 0, yes: 1, no: 2 }, _prefix: :was_incarcerated
  enum primary_was_incarcerated: { unfilled: 0, yes: 1, no: 2 }, _prefix: :primary_was_incarcerated
  enum spouse_was_incarcerated: { unfilled: 0, yes: 1, no: 2 }, _prefix: :spouse_was_incarcerated
  enum ssn_no_employment: { unfilled: 0, yes: 1, no: 2 }, _prefix: :ssn_no_employment
  enum household_excise_credit_claimed: { unfilled: 0, yes: 1, no: 2 }, _prefix: :household_excise_credit_claimed
  enum tribal_member: { unfilled: 0, yes: 1, no: 2 }, _prefix: :tribal_member
  enum armed_forces_member: { unfilled: 0, yes: 1, no: 2 }, _prefix: :armed_forces_member
  enum charitable_contributions: { unfilled: 0, yes: 1, no: 2 }, _prefix: :charitable_contributions
  enum eligibility_married_filing_separately: { unfilled: 0, yes: 1, no: 2 }, _prefix: :eligibility_married_filing_separately
  enum eligibility_529_for_non_qual_expense: { unfilled: 0, yes: 1, no: 2 }, _prefix: :eligibility_529_for_non_qual_expense
  enum made_az321_contributions: { unfilled: 0, yes: 1, no: 2 }, _prefix: :made_az321_contributions
  enum eligibility_lived_in_state: { unfilled: 0, yes: 1, no: 2 }, _prefix: :eligibility_lived_in_state
  enum eligibility_out_of_state_income: { unfilled: 0, yes: 1, no: 2 }, _prefix: :eligibility_out_of_state_income

  validates :made_az321_contributions, inclusion: { in: ["yes", "no"]}, on: :az321_form_create
  validates :az321_contributions, length: { maximum: 10 }

  validates :az322_contributions, length: { maximum: 10 }, on: :az322
  def federal_dependent_count_under_17
    self.dependents.select{ |dependent| dependent.under_17? }.length
  end

  def federal_dependent_count_over_17_non_qualifying_senior
    self.dependents.select{ |dependent| !dependent.under_17? && !dependent.is_qualifying_parent_or_grandparent? }.length
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

  def disqualified_from_excise_credit_df?
    agi_limit = if filing_status_mfj? || filing_status_hoh?
                  25000
                elsif filing_status_single? || filing_status_mfs?
                  12500
                end
    agi_over_limit = direct_file_data.fed_agi > agi_limit
    lacks_valid_ssn = primary.ssn.blank? || primary.has_itin?

    agi_over_limit || lacks_valid_ssn
  end

  def incarcerated_filer_count
    count = 0
    if use_old_incarcerated_column?
      count += 2 if was_incarcerated_yes?
    else
      count += 1 if primary_was_incarcerated_yes?
      count += 1 if spouse_was_incarcerated_yes?
    end

    count
  end

  # TODO: remove once column ignored
  def use_old_incarcerated_column?
    !was_incarcerated_unfilled? && primary_was_incarcerated_unfilled?
  end

  def disqualified_from_excise_credit_fyst?
    all_filers_incarcerated = was_incarcerated_yes? || (primary_was_incarcerated_yes? && spouse_was_incarcerated_yes?)
    whole_credit_already_claimed = use_old_incarcerated_column? && household_excise_credit_claimed_yes?
    all_filers_incarcerated || whole_credit_already_claimed || ssn_no_employment_yes? || direct_file_data.claimed_as_dependent?
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
        [dependent[:months_in_home], -dependent.calculate_age(inclusive_of_jan_1: false)]
      }
      if hoh_qualifying_dependent.nil?
        hoh_qualifying_dependent = hoh_qualifying_dependents.select { |dependent|
          dependent[:relationship] == "PARENT"
        }.max_by { |dependent| dependent.calculate_age(inclusive_of_jan_1: false) }
      end
      {
        :first_name => hoh_qualifying_dependent.first_name,
        :last_name => hoh_qualifying_dependent.last_name
      }
    end
  end
end
