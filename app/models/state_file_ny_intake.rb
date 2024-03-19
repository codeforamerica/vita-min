# == Schema Information
#
# Table name: state_file_ny_intakes
#
#  id                                 :bigint           not null, primary key
#  account_number                     :string
#  account_type                       :integer          default("unfilled"), not null
#  bank_name                          :string
#  confirmed_permanent_address        :integer          default("unfilled"), not null
#  confirmed_third_party_designee     :integer          default("unfilled"), not null
#  consented_to_terms_and_conditions  :integer          default("unfilled"), not null
#  contact_preference                 :integer          default("unfilled"), not null
#  current_sign_in_at                 :datetime
#  current_sign_in_ip                 :inet
#  current_step                       :string
#  date_electronic_withdrawal         :date
#  df_data_import_failed_at           :datetime
#  eligibility_lived_in_state         :integer          default("unfilled"), not null
#  eligibility_out_of_state_income    :integer          default("unfilled"), not null
#  eligibility_part_year_nyc_resident :integer          default("unfilled"), not null
#  eligibility_withdrew_529           :integer          default("unfilled"), not null
#  eligibility_yonkers                :integer          default("unfilled"), not null
#  email_address                      :citext
#  email_address_verified_at          :datetime
#  failed_attempts                    :integer          default(0), not null
#  federal_return_status              :string
#  hashed_ssn                         :string
#  household_cash_assistance          :integer
#  household_ny_additions             :integer
#  household_other_income             :integer
#  household_own_assessments          :integer
#  household_own_propety_tax          :integer
#  household_rent_adjustments         :integer
#  household_rent_amount              :integer
#  household_rent_own                 :integer          default("unfilled"), not null
#  household_ssi                      :integer
#  last_sign_in_at                    :datetime
#  last_sign_in_ip                    :inet
#  locale                             :string           default("en")
#  locked_at                          :datetime
#  mailing_country                    :string
#  mailing_state                      :string
#  message_tracker                    :jsonb
#  nursing_home                       :integer          default("unfilled"), not null
#  ny_mailing_apartment               :string
#  ny_mailing_city                    :string
#  ny_mailing_street                  :string
#  ny_mailing_zip                     :string
#  nyc_maintained_home                :integer          default("unfilled"), not null
#  nyc_residency                      :integer          default("unfilled"), not null
#  occupied_residence                 :integer          default("unfilled"), not null
#  payment_or_deposit_type            :integer          default("unfilled"), not null
#  permanent_address_outside_ny       :integer          default("unfilled"), not null
#  permanent_apartment                :string
#  permanent_city                     :string
#  permanent_street                   :string
#  permanent_zip                      :string
#  phone_number                       :string
#  phone_number_verified_at           :datetime
#  primary_birth_date                 :date
#  primary_email                      :string
#  primary_esigned                    :integer          default("unfilled"), not null
#  primary_esigned_at                 :datetime
#  primary_first_name                 :string
#  primary_last_name                  :string
#  primary_middle_initial             :string
#  primary_signature                  :string
#  property_over_limit                :integer          default("unfilled"), not null
#  public_housing                     :integer          default("unfilled"), not null
#  raw_direct_file_data               :text
#  referrer                           :string
#  residence_county                   :string
#  routing_number                     :string
#  sales_use_tax                      :integer
#  sales_use_tax_calculation_method   :integer          default("unfilled"), not null
#  school_district                    :string
#  school_district_number             :integer
#  sign_in_count                      :integer          default(0), not null
#  source                             :string
#  spouse_birth_date                  :date
#  spouse_esigned                     :integer          default("unfilled"), not null
#  spouse_esigned_at                  :datetime
#  spouse_first_name                  :string
#  spouse_last_name                   :string
#  spouse_middle_initial              :string
#  spouse_signature                   :string
#  unfinished_intake_ids              :text             default([]), is an Array
#  unsubscribed_from_email            :boolean          default(FALSE), not null
#  untaxed_out_of_state_purchases     :integer          default("unfilled"), not null
#  withdraw_amount                    :integer
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  federal_submission_id              :string
#  primary_state_id_id                :bigint
#  school_district_id                 :integer
#  spouse_state_id_id                 :bigint
#  visitor_id                         :string
#
# Indexes
#
#  index_state_file_ny_intakes_on_hashed_ssn           (hashed_ssn)
#  index_state_file_ny_intakes_on_primary_state_id_id  (primary_state_id_id)
#  index_state_file_ny_intakes_on_spouse_state_id_id   (spouse_state_id_id)
#
class StateFileNyIntake < StateFileBaseIntake
  STATE_CODE = 'ny'.freeze
  STATE_NAME = 'New York'.freeze
  STATE_CODE_AND_NAME = {
    STATE_CODE => STATE_NAME
  }.freeze
  LOCALITIES = [
    "NY",
    "N Y",
    "NWY",
    "NW Y",
    "NEWY",
    "BRONX",
    "BROOKLYN",
    "CITYNY",
    "STATEN",
    "QUEENS",
    "CITY NY",
    "CITYN Y",
    "CITYOFNY",
    "CITYOF NY",
    "CITY OFNY",
    "CITYOFN Y",
    "CTY OF NY",
    "MANHATTAN",
    "NEW YORK CIT",
  ].freeze
  VALID_TINS = [
    "270293117",
    "146013200"
  ].freeze

  encrypts :account_number, :routing_number, :raw_direct_file_data
  
  enum nyc_residency: { unfilled: 0, full_year: 1, part_year: 2, none: 3 }, _prefix: :nyc_residency
  enum nyc_maintained_home: { unfilled: 0, yes: 1, no: 2 }, _prefix: :nyc_maintained_home
  enum occupied_residence: { unfilled: 0, yes: 1, no: 2 }, _prefix: :occupied_residence
  enum property_over_limit: { unfilled: 0, yes: 1, no: 2 }, _prefix: :property_over_limit
  enum public_housing: { unfilled: 0, yes: 1, no: 2 }, _prefix: :public_housing
  enum nursing_home: { unfilled: 0, yes: 1, no: 2 }, _prefix: :nursing_home
  enum household_rent_own: { unfilled: 0, rent: 1, own: 2 }, _prefix: :household_rent_own
  enum confirmed_permanent_address: { unfilled: 0, yes: 1, no: 2 }, _prefix: :confirmed_permanent_address
  enum untaxed_out_of_state_purchases: { unfilled: 0, yes: 1, no: 2 }, _prefix: :untaxed_out_of_state_purchases
  enum sales_use_tax_calculation_method: { unfilled: 0, automated: 1, manual: 2 }, _prefix: :sales_use_tax_calculation_method
  enum eligibility_yonkers: { unfilled: 0, yes: 1, no: 2 }, _prefix: :eligibility_yonkers
  enum eligibility_part_year_nyc_resident: { unfilled: 0, yes: 1, no: 2 }, _prefix: :eligibility_part_year_nyc_resident
  enum eligibility_withdrew_529: { unfilled: 0, yes: 1, no: 2 }, _prefix: :eligibility_withdrew_529
  enum permanent_address_outside_ny: { unfilled: 0, yes: 1, no: 2 }, _prefix: :permanent_address_outside_ny
  enum confirmed_third_party_designee: { unfilled: 0, yes: 1, no: 2 }, _prefix: :confirmed_third_party_designee

  before_save do
    save_nil_enums_with_unfilled

    if untaxed_out_of_state_purchases_changed?(to: "no") || untaxed_out_of_state_purchases_changed?(to: "unfilled")
      self.sales_use_tax_calculation_method = "unfilled"
      self.sales_use_tax = nil
    end

    if sales_use_tax_calculation_method_changed?(to: "automated")
      self.sales_use_tax = calculate_sales_use_tax
    end

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

  def county_name
    district&.county_name
  end

  def county_code
    district&.county_code
  end

  def tax_calculator(include_source: false)
    Efile::Ny::It201.new(
      year: MultiTenantService.statefile.current_tax_year,
      intake: self,
      include_source: include_source
    )
  end

  def calculate_sales_use_tax
    fed_agi = direct_file_data&.fed_agi

    if fed_agi <= 15_000
      3
    elsif fed_agi.between?(15_001, 30_000)
      5
    elsif fed_agi.between?(30_001, 50_000)
      9
    elsif fed_agi.between?(50_001, 75_000)
      13
    elsif fed_agi.between?(75_001, 100_000)
      18
    elsif fed_agi.between?(100_001, 150_000)
      26
    elsif fed_agi.between?(150_001, 200_000)
      32
    elsif fed_agi >= 200_001
      sut = (0.000165 * fed_agi).round
      [sut, 125].min
    end
  end

  def ask_months_in_home?
    false
  end

  def ach_debit_transaction?
    refund_or_owe_taxes_type == :owe && self.payment_or_deposit_type_direct_deposit?
  end

  IRC_125_CODES = ['IRC125S', 'IRS125']
  YONKERS_CODES = ['YK', 'YON', 'YNK', 'CITYOFYK', 'CTYOFYKR', 'CITYOF YK', 'CTY OF YK']
  def disqualifying_df_data_reason
    w2_states = direct_file_data.parsed_xml.css('W2StateLocalTaxGrp W2StateTaxGrp StateAbbreviationCd')
    return :has_out_of_state_w2 if w2_states.any? do |state|
      (state.text || '').upcase != state_code.upcase
    end

    box_14_nodes = direct_file_data.parsed_xml.css('IRSW2 OtherDeductionsBenefitsGrp')
    return :has_irc_125_code if box_14_nodes.any? do |deduction|
      IRC_125_CODES.include?(deduction.at('Desc')&.text)
    end

    return :has_yonkers_income if box_14_nodes.any? do |deduction|
      YONKERS_CODES.include?(deduction.at('Desc')&.text)
    end
    box_20_nodes = direct_file_data.parsed_xml.css('IRSW2 W2StateLocalTaxGrp W2StateTaxGrp W2LocalTaxGrp LocalityNm')
    return :has_yonkers_income if box_20_nodes.any? do |locality_name|
      YONKERS_CODES.include?(locality_name.text)
    end
  end

  def disqualifying_eligibility_rules
    {
      eligibility_lived_in_state: "no",
      eligibility_yonkers: "yes",
      eligibility_out_of_state_income: "yes",
      eligibility_part_year_nyc_resident: "yes",
      eligibility_withdrew_529: "yes",
      permanent_address_outside_ny: "yes",
      nyc_residency: "part_year",
      nyc_maintained_home: "yes"
    }
  end

  def self.locality_nm_valid?(locality_nm)
    locality_nm = locality_nm.upcase
    (LOCALITIES.detect { |loc| locality_nm.starts_with?(loc) }).present?
  end

  def validate_state_specific_w2_requirements(w2)
    if w2.locality_nm.present? && !self.class.locality_nm_valid?(w2.locality_nm)
      w2.errors.add(:locality_nm, I18n.t("state_file.questions.ny_w2.edit.locality_nm_error"))
    end
  end

  def validate_state_specific_1099_g_requirements(state_file1099_g)
    unless VALID_TINS.include?(state_file1099_g.payer_tin)
      state_file1099_g.errors.add(:payer_tin, I18n.t("errors.attributes.payer_tin_ny_invalid"))
    end
  end

  def invalid_df_w2?(df_w2)
    if nyc_residency_full_year?
      return true if df_w2.LocalWagesAndTipsAmt == 0 || df_w2.LocalityNm.blank?
    end
    return true if df_w2.LocalityNm.present? && !self.class.locality_nm_valid?(df_w2.LocalityNm)
    super
  end

  private

  def district
    @district ||= NySchoolDistricts.find_by_id(school_district_id)
  end
end
