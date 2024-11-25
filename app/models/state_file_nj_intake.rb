# == Schema Information
#
# Table name: state_file_nj_intakes
#
#  id                                                     :bigint           not null, primary key
#  account_number                                         :string
#  account_type                                           :integer          default("unfilled"), not null
#  claimed_as_dep                                         :integer
#  claimed_as_eitc_qualifying_child                       :integer          default("unfilled"), not null
#  consented_to_terms_and_conditions                      :integer          default("unfilled"), not null
#  contact_preference                                     :integer          default("unfilled"), not null
#  county                                                 :string
#  current_sign_in_at                                     :datetime
#  current_sign_in_ip                                     :inet
#  current_step                                           :string
#  date_electronic_withdrawal                             :date
#  df_data_import_succeeded_at                            :datetime
#  df_data_imported_at                                    :datetime
#  eligibility_all_members_health_insurance               :integer          default("unfilled"), not null
#  eligibility_lived_in_state                             :integer          default("unfilled"), not null
#  eligibility_out_of_state_income                        :integer          default("unfilled"), not null
#  email_address                                          :citext
#  email_address_verified_at                              :datetime
#  estimated_tax_payments                                 :decimal(12, 2)
#  failed_attempts                                        :integer          default(0), not null
#  fed_taxable_income                                     :integer
#  fed_wages                                              :integer
#  federal_return_status                                  :string
#  hashed_ssn                                             :string
#  homeowner_home_subject_to_property_taxes               :integer          default("unfilled"), not null
#  homeowner_main_home_multi_unit                         :integer          default("unfilled"), not null
#  homeowner_main_home_multi_unit_max_four_one_commercial :integer          default("unfilled"), not null
#  homeowner_more_than_one_main_home_in_nj                :integer          default("unfilled"), not null
#  homeowner_same_home_spouse                             :integer          default("unfilled"), not null
#  homeowner_shared_ownership_not_spouse                  :integer          default("unfilled"), not null
#  household_rent_own                                     :integer          default("unfilled"), not null
#  last_sign_in_at                                        :datetime
#  last_sign_in_ip                                        :inet
#  locale                                                 :string           default("en")
#  locked_at                                              :datetime
#  medical_expenses                                       :decimal(12, 2)   default(0.0), not null
#  message_tracker                                        :jsonb
#  municipality_code                                      :string
#  municipality_name                                      :string
#  payment_or_deposit_type                                :integer          default("unfilled"), not null
#  permanent_apartment                                    :string
#  permanent_city                                         :string
#  permanent_street                                       :string
#  permanent_zip                                          :string
#  phone_number                                           :string
#  phone_number_verified_at                               :datetime
#  primary_birth_date                                     :date
#  primary_contribution_gubernatorial_elections           :integer          default("unfilled"), not null
#  primary_disabled                                       :integer          default("unfilled"), not null
#  primary_esigned                                        :integer          default("unfilled"), not null
#  primary_esigned_at                                     :datetime
#  primary_first_name                                     :string
#  primary_last_name                                      :string
#  primary_middle_initial                                 :string
#  primary_signature                                      :string
#  primary_ssn                                            :string
#  primary_suffix                                         :string
#  primary_veteran                                        :integer          default("unfilled"), not null
#  property_tax_paid                                      :decimal(12, 2)
#  raw_direct_file_data                                   :text
#  raw_direct_file_intake_data                            :jsonb
#  referrer                                               :string
#  rent_paid                                              :decimal(12, 2)
#  routing_number                                         :string
#  sales_use_tax                                          :decimal(12, 2)
#  sales_use_tax_calculation_method                       :integer          default("unfilled"), not null
#  sign_in_count                                          :integer          default(0), not null
#  source                                                 :string
#  spouse_birth_date                                      :date
#  spouse_claimed_as_eitc_qualifying_child                :integer          default("unfilled"), not null
#  spouse_contribution_gubernatorial_elections            :integer          default("unfilled"), not null
#  spouse_disabled                                        :integer          default("unfilled"), not null
#  spouse_esigned                                         :integer          default("unfilled"), not null
#  spouse_esigned_at                                      :datetime
#  spouse_first_name                                      :string
#  spouse_last_name                                       :string
#  spouse_middle_initial                                  :string
#  spouse_ssn                                             :string
#  spouse_suffix                                          :string
#  spouse_veteran                                         :integer          default("unfilled"), not null
#  tenant_access_kitchen_bath                             :integer          default("unfilled"), not null
#  tenant_building_multi_unit                             :integer          default("unfilled"), not null
#  tenant_home_subject_to_property_taxes                  :integer          default("unfilled"), not null
#  tenant_more_than_one_main_home_in_nj                   :integer          default("unfilled"), not null
#  tenant_same_home_spouse                                :integer          default("unfilled"), not null
#  tenant_shared_rent_not_spouse                          :integer          default("unfilled"), not null
#  unfinished_intake_ids                                  :text             default([]), is an Array
#  unsubscribed_from_email                                :boolean          default(FALSE), not null
#  untaxed_out_of_state_purchases                         :integer          default("unfilled"), not null
#  withdraw_amount                                        :integer
#  created_at                                             :datetime         not null
#  updated_at                                             :datetime         not null
#  federal_submission_id                                  :string
#  primary_state_id_id                                    :bigint
#  spouse_state_id_id                                     :bigint
#  visitor_id                                             :string
#
# Indexes
#
#  index_state_file_nj_intakes_on_email_address        (email_address)
#  index_state_file_nj_intakes_on_hashed_ssn           (hashed_ssn)
#  index_state_file_nj_intakes_on_primary_state_id_id  (primary_state_id_id)
#  index_state_file_nj_intakes_on_spouse_state_id_id   (spouse_state_id_id)
#
class StateFileNjIntake < StateFileBaseIntake
  encrypts :account_number, :routing_number, :raw_direct_file_data, :raw_direct_file_intake_data

  enum household_rent_own: { unfilled: 0, rent: 1, own: 2, neither: 3, both: 4 }, _prefix: :household_rent_own

  enum eligibility_lived_in_state: { unfilled: 0, yes: 1, no: 2 }, _prefix: :eligibility_lived_in_state
  enum eligibility_out_of_state_income: { unfilled: 0, yes: 1, no: 2 }, _prefix: :eligibility_out_of_state_income
  enum primary_disabled: { unfilled: 0, yes: 1, no: 2 }, _prefix: :primary_disabled
  enum spouse_disabled: { unfilled: 0, yes: 1, no: 2 }, _prefix: :spouse_disabled

  enum primary_veteran: { unfilled: 0, yes: 1, no: 2 }, _prefix: :primary_veteran
  enum spouse_veteran: { unfilled: 0, yes: 1, no: 2 }, _prefix: :spouse_veteran

  enum untaxed_out_of_state_purchases: { unfilled: 0, yes: 1, no: 2 }, _prefix: :untaxed_out_of_state_purchases
  enum sales_use_tax_calculation_method: { unfilled: 0, automated: 1, manual: 2 }, _prefix: :sales_use_tax_calculation_method

  enum claimed_as_eitc_qualifying_child: { unfilled: 0, yes: 1, no: 2}, _prefix: :claimed_as_eitc_qualifying_child
  enum spouse_claimed_as_eitc_qualifying_child: { unfilled: 0, yes: 1, no: 2}, _prefix: :spouse_claimed_as_eitc_qualifying_child

  enum primary_contribution_gubernatorial_elections: { unfilled: 0, yes: 1, no: 2}, _prefix: :primary_contribution_gubernatorial_elections
  enum spouse_contribution_gubernatorial_elections: { unfilled: 0, yes: 1, no: 2}, _prefix: :spouse_contribution_gubernatorial_elections

  enum eligibility_all_members_health_insurance: { unfilled: 0, yes: 1, no: 2 }, _prefix: :eligibility_all_members_health_insurance

  # checkboxes - "unfilled" means not-yet-seen because it saves as "no" when unchecked
  enum homeowner_home_subject_to_property_taxes: { unfilled: 0, yes: 1, no: 2}, _prefix: :homeowner_home_subject_to_property_taxes
  enum homeowner_main_home_multi_unit: { unfilled: 0, yes: 1, no: 2}, _prefix: :homeowner_main_home_multi_unit
  enum homeowner_main_home_multi_unit_max_four_one_commercial: { unfilled: 0, yes: 1, no: 2}, _prefix: :homeowner_main_home_multi_unit_max_four_one_commercial
  enum homeowner_more_than_one_main_home_in_nj: { unfilled: 0, yes: 1, no: 2}, _prefix: :homeowner_more_than_one_main_home_in_nj
  enum homeowner_shared_ownership_not_spouse: { unfilled: 0, yes: 1, no: 2}, _prefix: :homeowner_shared_ownership_not_spouse
  enum homeowner_same_home_spouse: { unfilled: 0, yes: 1, no: 2}, _prefix: :homeowner_same_home_spouse

  enum tenant_home_subject_to_property_taxes: { unfilled: 0, yes: 1, no: 2}, _prefix: :tenant_home_subject_to_property_taxes
  enum tenant_building_multi_unit: { unfilled: 0, yes: 1, no: 2}, _prefix: :tenant_building_multi_unit
  enum tenant_access_kitchen_bath: { unfilled: 0, yes: 1, no: 2}, _prefix: :tenant_access_kitchen_bath
  enum tenant_more_than_one_main_home_in_nj: { unfilled: 0, yes: 1, no: 2}, _prefix: :tenant_more_than_one_main_home_in_nj
  enum tenant_shared_rent_not_spouse: { unfilled: 0, yes: 1, no: 2}, _prefix: :tenant_shared_rent_not_spouse
  enum tenant_same_home_spouse: { unfilled: 0, yes: 1, no: 2}, _prefix: :tenant_same_home_spouse

  def calculate_sales_use_tax
    nj_gross_income = calculator.lines[:NJ1040_LINE_29].value
    calculator.calculate_use_tax(nj_gross_income)
  end

  def disqualifying_df_data_reason
    w2_states = direct_file_data.parsed_xml.css('W2StateLocalTaxGrp W2StateTaxGrp StateAbbreviationCd')
    return :has_out_of_state_w2 if w2_states.any? do |state|
      !(state.text || '').casecmp(state_code).zero?
    end

    tax_exempt_interest_income = calculator.calculate_tax_exempt_interest_income
    return :exempt_interest_exceeds_10k if tax_exempt_interest_income > 10_000
  end

  def eligibility_claimed_as_dependent?
    if self.filing_status_mfj?
      self.direct_file_data.claimed_as_dependent? && self.direct_file_data.spouse_is_a_dependent?
    else
      self.direct_file_data.claimed_as_dependent?
    end
  end

  def eligibility_made_less_than_threshold?
    nj_gross_income = calculator.lines[:NJ1040_LINE_29].value
    threshold = self.filing_status_single? || self.filing_status_mfs? ? 10_000 : 20_000
    nj_gross_income <= threshold
  end

  def health_insurance_eligibility
    if self.eligibility_all_members_health_insurance_no?
      has_exception = self.eligibility_made_less_than_threshold? || self.eligibility_claimed_as_dependent?
      has_exception ? "eligible" : "ineligible"
    else
      "eligible"
    end
  end

  def disqualifying_eligibility_rules
    {
      health_insurance_eligibility: "ineligible"
    }
  end
end

