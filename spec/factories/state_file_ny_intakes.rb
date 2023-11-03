# == Schema Information
#
# Table name: state_file_ny_intakes
#
#  id                               :bigint           not null, primary key
#  account_number                   :string
#  account_type                     :integer          default("unfilled"), not null
#  amount_electronic_withdrawal     :integer
#  amount_owed_pay_electronically   :integer          default("unfilled"), not null
#  claimed_as_dep                   :integer          default("unfilled"), not null
#  confirmed_permanent_address      :integer          default("unfilled"), not null
#  contact_preference               :integer          default("unfilled"), not null
#  current_step                     :string
#  date_electronic_withdrawal       :date
#  email_address                    :citext
#  email_address_verified_at        :datetime
#  household_cash_assistance        :integer
#  household_fed_agi                :integer
#  household_ny_additions           :integer
#  household_other_income           :integer
#  household_own_assessments        :integer
#  household_own_propety_tax        :integer
#  household_rent_adjustments       :integer
#  household_rent_amount            :integer
#  household_rent_own               :integer          default("unfilled"), not null
#  household_ssi                    :integer
#  mailing_country                  :string
#  mailing_state                    :string
#  nursing_home                     :integer          default("unfilled"), not null
#  ny_414h_retirement               :integer
#  ny_mailing_apartment             :string
#  ny_mailing_city                  :string
#  ny_mailing_street                :string
#  ny_mailing_zip                   :string
#  ny_other_additions               :integer
#  nyc_full_year_resident           :integer          default("unfilled"), not null
#  occupied_residence               :integer          default("unfilled"), not null
#  permanent_apartment              :string
#  permanent_city                   :string
#  permanent_street                 :string
#  permanent_zip                    :string
#  phone_number                     :string
#  phone_number_verified_at         :datetime
#  primary_birth_date               :date
#  primary_email                    :string
#  primary_first_name               :string
#  primary_last_name                :string
#  primary_middle_initial           :string
#  primary_signature                :string
#  property_over_limit              :integer          default("unfilled"), not null
#  public_housing                   :integer          default("unfilled"), not null
#  raw_direct_file_data             :text
#  referrer                         :string
#  refund_choice                    :integer          default("unfilled"), not null
#  residence_county                 :string
#  routing_number                   :string
#  sales_use_tax                    :integer
#  sales_use_tax_calculation_method :integer          default("unfilled"), not null
#  school_district                  :string
#  school_district_number           :integer
#  source                           :string
#  spouse_birth_date                :date
#  spouse_first_name                :string
#  spouse_last_name                 :string
#  spouse_middle_initial            :string
#  spouse_signature                 :string
#  untaxed_out_of_state_purchases   :integer          default("unfilled"), not null
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  visitor_id                       :string
#
FactoryBot.define do
  factory :state_file_ny_intake do
    transient do
      filing_status { 'single' }
    end

    raw_direct_file_data { File.read(Rails.root.join('app', 'controllers', 'state_file', 'questions', 'df_return_sample.xml')) }
    claimed_as_dep { 'no' }
    primary_first_name { "New" }
    primary_last_name { "Yorker" }
    permanent_street { direct_file_data.mailing_street }
    permanent_city { direct_file_data.mailing_city }
    permanent_zip { direct_file_data.mailing_zip }
    nyc_full_year_resident { 'yes' }
    school_district { "Cool School" }
    school_district_number { 123 }

    after(:build) do |intake, evaluator|
      if evaluator.filing_status
        numeric_status = {
          single: 1,
          married_filing_jointly: 2,
          married_filing_separately: 3,
          head_of_household: 4,
          qualifying_widow: 5,
        }[evaluator.filing_status.to_sym] || evaluator.filing_status
        intake.direct_file_data.filing_status = numeric_status
      end
    end
  end
end
