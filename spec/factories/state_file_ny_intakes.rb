# == Schema Information
#
# Table name: state_file_ny_intakes
#
#  id                             :bigint           not null, primary key
#  account_number                 :string
#  account_type                   :integer          default("unfilled"), not null
#  amount_electronic_withdrawal   :integer
#  amount_owed_pay_electronically :integer          default("unfilled"), not null
#  claimed_as_dep                 :integer          not null
#  current_step                   :string
#  date_electronic_withdrawal     :date
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
#  nyc_resident_e                 :integer          default("unfilled"), not null
#  occupied_residence             :integer          default("unfilled"), not null
#  permanent_apartment            :string
#  permanent_city                 :string
#  permanent_street               :string
#  permanent_zip                  :string
#  primary_email                  :string
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
#  spouse_signature               :string
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  visitor_id                     :string
#
FactoryBot.define do
  factory :state_file_ny_intake do
    tax_return_year { 2022 }
    claimed_as_dep { 'no' }
    filing_status { 'single' }
    primary_first_name { "New" }
    primary_last_name { "Yorker" }
    primary_ssn { "123445555" }
    primary_dob { Date.new(1985, 1, 3) }
    mailing_street { "123 main st" }
    mailing_city { "New York" }
    mailing_state { "NY" }
    mailing_zip { "10001" }
    permanent_street { mailing_street }
    permanent_city { mailing_city }
    permanent_zip { mailing_zip }
    nyc_resident_e { 'yes' }
    school_district { 123 }
    school_district_number { 'Cool School' }
    fed_wages { 123 }
    fed_taxable_income { 12 }
    fed_unemployment { 34 }
    fed_taxable_ssb { 4 }
    total_fed_adjustments_identify { "wrenches" }
    total_fed_adjustments { 45 }
    total_state_tax_withheld { 56 }
  end
end
