# == Schema Information
#
# Table name: state_file_ny_intakes
#
#  id                             :bigint           not null, primary key
#  account_number                 :string
#  account_type                   :integer          default("unfilled"), not null
#  amount_electronic_withdrawal   :integer
#  amount_owed_pay_electronically :integer          default("unfilled"), not null
#  claimed_as_dep                 :integer          default("unfilled"), not null
#  confirmed_permanent_address    :integer          default("unfilled"), not null
#  contact_preference             :integer          default("unfilled"), not null
#  current_step                   :string
#  date_electronic_withdrawal     :date
#  email_address                  :citext
#  household_cash_assistance      :integer
#  household_fed_agi              :integer
#  household_ny_additions         :integer
#  household_other_income         :integer
#  household_own_assessments      :integer
#  household_own_propety_tax      :integer
#  household_rent_adjustments     :integer
#  household_rent_amount          :integer
#  household_rent_own             :integer          default("unfilled"), not null
#  household_ssi                  :integer
#  mailing_country                :string
#  mailing_state                  :string
#  nursing_home                   :integer          default("unfilled"), not null
#  ny_414h_retirement             :integer
#  ny_mailing_apartment           :string
#  ny_mailing_city                :string
#  ny_mailing_street              :string
#  ny_mailing_zip                 :string
#  ny_other_additions             :integer
#  nyc_full_year_resident         :integer          default("unfilled"), not null
#  occupied_residence             :integer          default("unfilled"), not null
#  permanent_apartment            :string
#  permanent_city                 :string
#  permanent_street               :string
#  permanent_zip                  :string
#  phone_number                   :string
#  primary_birth_date             :date
#  primary_email                  :string
#  primary_first_name             :string
#  primary_last_name              :string
#  primary_middle_initial         :string
#  primary_signature              :string
#  property_over_limit            :integer          default("unfilled"), not null
#  public_housing                 :integer          default("unfilled"), not null
#  raw_direct_file_data           :text
#  refund_choice                  :integer          default("unfilled"), not null
#  residence_county               :string
#  routing_number                 :string
#  sales_use_tax                  :integer
#  school_district                :string
#  school_district_number         :integer
#  spouse_birth_date              :date
#  spouse_first_name              :string
#  spouse_last_name               :string
#  spouse_middle_initial          :string
#  spouse_signature               :string
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  visitor_id                     :string
#
class StateFileNyIntake < StateFileBaseIntake
  encrypts :account_number, :routing_number, :raw_direct_file_data
  enum nyc_full_year_resident: { unfilled: 0, yes: 1, no: 2 }, _prefix: :nyc_full_year_resident
  enum refund_choice: { unfilled: 0, paper: 1, direct_deposit: 2 }, _prefix: :refund_choice
  enum account_type: { unfilled: 0, personal_checking: 1, personal_savings: 2, business_checking: 3, business_savings: 4 }, _prefix: :account_type
  enum amount_owed_pay_electronically: { unfilled: 0, yes: 1, no: 2 }, _prefix: :amount_owed_pay_electronically
  enum occupied_residence: { unfilled: 0, yes: 1, no: 2 }, _prefix: :occupied_residence
  enum property_over_limit: { unfilled: 0, yes: 1, no: 2 }, _prefix: :property_over_limit
  enum public_housing: { unfilled: 0, yes: 1, no: 2 }, _prefix: :public_housing
  enum nursing_home: { unfilled: 0, yes: 1, no: 2 }, _prefix: :nursing_home
  enum household_rent_own: { unfilled: 0, rent: 1, own: 2 }, _prefix: :household_rent_own
  enum confirmed_permanent_address: { unfilled: 0, yes: 1, no: 2 }, _prefix: :confirmed_permanent_address

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

  def ask_months_in_home?
    false
  end

  def ask_primary_dob?
    true
  end

  def ask_spouse_dob?
    filing_status == :married_filing_jointly
  end
end
