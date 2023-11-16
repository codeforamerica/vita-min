# == Schema Information
#
# Table name: state_file_ny_intakes
#
#  id                                 :bigint           not null, primary key
#  account_number                     :string
#  account_type                       :integer          default("unfilled"), not null
#  amount_electronic_withdrawal       :integer
#  amount_owed_pay_electronically     :integer          default("unfilled"), not null
#  bank_name                          :string
#  claimed_as_dep                     :integer          default("unfilled"), not null
#  confirmed_permanent_address        :integer          default("unfilled"), not null
#  contact_preference                 :integer          default("unfilled"), not null
#  current_step                       :string
#  date_electronic_withdrawal         :date
#  eligibility_lived_in_state         :integer          default("unfilled"), not null
#  eligibility_out_of_state_income    :integer          default("unfilled"), not null
#  eligibility_part_year_nyc_resident :integer          default("unfilled"), not null
#  eligibility_withdrew_529           :integer          default("unfilled"), not null
#  eligibility_yonkers                :integer          default("unfilled"), not null
#  email_address                      :citext
#  email_address_verified_at          :datetime
#  household_cash_assistance          :integer
#  household_fed_agi                  :integer
#  household_ny_additions             :integer
#  household_other_income             :integer
#  household_own_assessments          :integer
#  household_own_propety_tax          :integer
#  household_rent_adjustments         :integer
#  household_rent_amount              :integer
#  household_rent_own                 :integer          default("unfilled"), not null
#  household_ssi                      :integer
#  mailing_country                    :string
#  mailing_state                      :string
#  nursing_home                       :integer          default("unfilled"), not null
#  ny_mailing_apartment               :string
#  ny_mailing_city                    :string
#  ny_mailing_street                  :string
#  ny_mailing_zip                     :string
#  ny_other_additions                 :integer
#  nyc_full_year_resident             :integer          default("unfilled"), not null
#  occupied_residence                 :integer          default("unfilled"), not null
#  payment_or_deposit_type            :integer          default("unfilled"), not null
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
#  refund_choice                      :integer          default("unfilled"), not null
#  residence_county                   :string
#  routing_number                     :string
#  sales_use_tax                      :integer
#  sales_use_tax_calculation_method   :integer          default("unfilled"), not null
#  school_district                    :string
#  school_district_number             :integer
#  source                             :string
#  spouse_birth_date                  :date
#  spouse_esigned                     :integer          default("unfilled"), not null
#  spouse_esigned_at                  :datetime
#  spouse_first_name                  :string
#  spouse_last_name                   :string
#  spouse_middle_initial              :string
#  spouse_signature                   :string
#  untaxed_out_of_state_purchases     :integer          default("unfilled"), not null
#  withdraw_amount                    :integer
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  primary_state_id_id                :bigint
#  spouse_state_id_id                 :bigint
#  visitor_id                         :string
#
# Indexes
#
#  index_state_file_ny_intakes_on_primary_state_id_id  (primary_state_id_id)
#  index_state_file_ny_intakes_on_spouse_state_id_id   (spouse_state_id_id)
#
class StateFileNyIntake < StateFileBaseIntake
  belongs_to :primary_state_id, class_name: "StateId", optional: true
  belongs_to :spouse_state_id, class_name: "StateId", optional: true
  accepts_nested_attributes_for :primary_state_id, :spouse_state_id
  encrypts :account_number, :routing_number, :raw_direct_file_data
  enum nyc_full_year_resident: { unfilled: 0, yes: 1, no: 2 }, _prefix: :nyc_full_year_resident
  enum refund_choice: { unfilled: 0, paper: 1, direct_deposit: 2 }, _prefix: :refund_choice
  enum account_type: { unfilled: 0, checking: 1, savings: 2, unspecified: 3 }, _prefix: :account_type
  enum amount_owed_pay_electronically: { unfilled: 0, yes: 1, no: 2 }, _prefix: :amount_owed_pay_electronically
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
  enum primary_esigned: { unfilled: 0, yes: 1, no: 2 }, _prefix: :primary_esigned
  enum spouse_esigned: { unfilled: 0, yes: 1, no: 2 }, _prefix: :spouse_esigned
  enum payment_or_deposit_type: { unfilled: 0, direct_deposit: 1, mail: 2 }, _prefix: :payment_or_deposit_type

  before_save do
    if untaxed_out_of_state_purchases_changed?(to: "no") || untaxed_out_of_state_purchases_changed?(to: "unfilled")
      self.sales_use_tax_calculation_method = "unfilled"
      self.sales_use_tax = nil
    end

    if sales_use_tax_calculation_method_changed?(to: "automated")
      self.sales_use_tax = calculate_sales_use_tax
    end

    if payment_or_deposit_type_changed?(to: "mail")
      self.account_type = "unfilled"
      self.bank_name = nil
      self.routing_number = nil
      self.account_number = nil
    end
  end

  def state_code
    'ny'
  end

  def state_name
    'New York'
  end

  def tax_calculator(include_source: false)
    Efile::Ny::It201.new(
      year: 2022,
      filing_status: filing_status.to_sym,
      claimed_as_dependent: claimed_as_dep_yes?,
      intake: self,
      direct_file_data: direct_file_data,
      nyc_full_year_resident: nyc_full_year_resident_yes?,
      dependent_count: dependents.length,
      include_source: include_source
    )
  end

  def calculated_refund_or_owed_amount
    calculator = tax_calculator
    calculator.calculate
    calculator.refund_or_owed_amount
  end

  def calculate_sales_use_tax
    return unless household_fed_agi

    if household_fed_agi <= 15_000
      3
    elsif household_fed_agi.between?(15_001, 30_000)
      7
    elsif household_fed_agi.between?(30_001, 50_000)
      11
    elsif household_fed_agi.between?(50_001, 75_000)
      17
    elsif household_fed_agi.between?(75_001, 100_000)
      23
    elsif household_fed_agi.between?(100_001, 150_000)
      29
    elsif household_fed_agi.between?(150_001, 200_000)
      38
    elsif household_fed_agi >= 200_001
      sut = (0.000195 * household_fed_agi).round
      [sut, 125].min
    end
  end

  def ask_months_in_home?
    false
  end

  def ask_primary_dob?
    true
  end

  def ask_spouse_name?
    [:married_filing_jointly, :married_filing_separately].include? filing_status
  end

  def ask_spouse_dob?
    filing_status_mfj?
  end

  def disqualifying_eligibility_rules
    {
      eligibility_lived_in_state: "no",
      eligibility_yonkers: "yes",
      eligibility_out_of_state_income: "yes",
      eligibility_part_year_nyc_resident: "yes",
      eligibility_withdrew_529: "yes"
    }
  end
end
