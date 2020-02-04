# == Schema Information
#
# Table name: intakes
#
#  id                            :bigint           not null, primary key
#  additional_info               :string
#  adopted_child                 :integer          default("unfilled"), not null
#  bought_health_insurance       :integer          default("unfilled"), not null
#  divorced                      :integer          default("unfilled"), not null
#  divorced_year                 :string
#  filing_joint                  :integer          default(0), not null
#  had_asset_sale_income         :integer          default("unfilled"), not null
#  had_debt_forgiven             :integer          default("unfilled"), not null
#  had_disability_income         :integer          default("unfilled"), not null
#  had_disaster_loss             :integer          default("unfilled"), not null
#  had_farm_income               :integer          default("unfilled"), not null
#  had_gambling_income           :integer          default("unfilled"), not null
#  had_hsa                       :integer          default("unfilled"), not null
#  had_interest_income           :integer          default("unfilled"), not null
#  had_local_tax_refund          :integer          default("unfilled"), not null
#  had_other_income              :integer          default("unfilled"), not null
#  had_rental_income             :integer          default("unfilled"), not null
#  had_retirement_income         :integer          default("unfilled"), not null
#  had_self_employment_income    :integer          default("unfilled"), not null
#  had_social_security_income    :integer          default("unfilled"), not null
#  had_student_in_family         :integer          default("unfilled"), not null
#  had_tax_credit_disallowed     :integer          default("unfilled"), not null
#  had_tips                      :integer          default("unfilled"), not null
#  had_unemployment_income       :integer          default("unfilled"), not null
#  had_wages                     :integer          default("unfilled"), not null
#  job_count                     :integer
#  lived_with_spouse             :integer          default("unfilled"), not null
#  made_estimated_tax_payments   :integer          default("unfilled"), not null
#  married                       :integer          default("unfilled"), not null
#  married_all_year              :integer          default("unfilled"), not null
#  other_income_types            :string
#  paid_alimony                  :integer          default("unfilled"), not null
#  paid_charitable_contributions :integer          default("unfilled"), not null
#  paid_dependent_care           :integer          default("unfilled"), not null
#  paid_local_tax                :integer          default("unfilled"), not null
#  paid_medical_expenses         :integer          default("unfilled"), not null
#  paid_mortgage_interest        :integer          default("unfilled"), not null
#  paid_retirement_contributions :integer          default("unfilled"), not null
#  paid_school_supplies          :integer          default("unfilled"), not null
#  paid_student_loan_interest    :integer          default("unfilled"), not null
#  received_alimony              :integer          default("unfilled"), not null
#  received_homebuyer_credit     :integer          default("unfilled"), not null
#  received_irs_letter           :integer          default("unfilled"), not null
#  reported_asset_sale_loss      :integer          default("unfilled"), not null
#  reported_self_employment_loss :integer          default("unfilled"), not null
#  separated                     :integer          default("unfilled"), not null
#  separated_year                :string
#  sold_a_home                   :integer          default("unfilled"), not null
#  widowed                       :integer          default("unfilled"), not null
#  widowed_year                  :string
#  created_at                    :datetime
#  updated_at                    :datetime
#

FactoryBot.define do
  factory :intake do
    had_wages { :unfilled }
  end
end
