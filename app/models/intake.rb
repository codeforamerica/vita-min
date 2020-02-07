# == Schema Information
#
# Table name: intakes
#
#  id                            :bigint           not null, primary key
#  additional_info               :string
#  adopted_child                 :integer          default("unfilled"), not null
#  bought_health_insurance       :integer          default("unfilled"), not null
#  city                          :string
#  divorced                      :integer          default("unfilled"), not null
#  divorced_year                 :string
#  filing_joint                  :integer          default("unfilled"), not null
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
#  referrer                      :string
#  reported_asset_sale_loss      :integer          default("unfilled"), not null
#  reported_self_employment_loss :integer          default("unfilled"), not null
#  separated                     :integer          default("unfilled"), not null
#  separated_year                :string
#  sold_a_home                   :integer          default("unfilled"), not null
#  source                        :string
#  state                         :string
#  street_address                :string
#  widowed                       :integer          default("unfilled"), not null
#  widowed_year                  :string
#  zip_code                      :string
#  created_at                    :datetime
#  updated_at                    :datetime
#

class Intake < ApplicationRecord
  has_many :users, -> { order(created_at: :asc) }
  has_many :documents, -> { order(created_at: :asc) }

  enum adopted_child: { unfilled: 0, yes: 1, no: 2 }, _prefix: :adopted_child
  enum bought_health_insurance: { unfilled: 0, yes: 1, no: 2 }, _prefix: :bought_health_insurance
  enum divorced: { unfilled: 0, yes: 1, no: 2 }, _prefix: :divorced
  enum filing_joint: { unfilled: 0, yes: 1, no: 2 }, _prefix: :filing_joint
  enum had_asset_sale_income: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_asset_sale_income
  enum had_debt_forgiven: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_debt_forgiven
  enum had_disability_income: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_disability_income
  enum had_disaster_loss: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_disaster_loss
  enum had_farm_income: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_farm_income
  enum had_gambling_income: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_gambling_income
  enum had_hsa: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_hsa
  enum had_interest_income: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_interest_income
  enum had_local_tax_refund: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_local_tax_refund
  enum had_other_income: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_other_income
  enum had_rental_income: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_rental_income
  enum had_retirement_income: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_retirement_income
  enum had_self_employment_income: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_self_employment_income
  enum had_social_security_income: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_social_security_income
  enum had_student_in_family: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_student_in_family
  enum had_tax_credit_disallowed: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_tax_credit_disallowed
  enum had_tips: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_tips
  enum had_unemployment_income: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_unemployment_income
  enum had_wages: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_wages
  enum lived_with_spouse: { unfilled: 0, yes: 1, no: 2 }, _prefix: :lived_with_spouse
  enum made_estimated_tax_payments: { unfilled: 0, yes: 1, no: 2 }, _prefix: :made_estimated_tax_payments
  enum married: { unfilled: 0, yes: 1, no: 2 }, _prefix: :married
  enum married_all_year: { unfilled: 0, yes: 1, no: 2 }, _prefix: :married_all_year
  enum paid_alimony: { unfilled: 0, yes: 1, no: 2 }, _prefix: :paid_alimony
  enum paid_charitable_contributions: { unfilled: 0, yes: 1, no: 2 }, _prefix: :paid_charitable_contributions
  enum paid_dependent_care: { unfilled: 0, yes: 1, no: 2 }, _prefix: :paid_dependent_care
  enum paid_local_tax: { unfilled: 0, yes: 1, no: 2 }, _prefix: :paid_local_tax
  enum paid_medical_expenses: { unfilled: 0, yes: 1, no: 2 }, _prefix: :paid_medical_expenses
  enum paid_mortgage_interest: { unfilled: 0, yes: 1, no: 2 }, _prefix: :paid_mortgage_interest
  enum paid_retirement_contributions: { unfilled: 0, yes: 1, no: 2 }, _prefix: :paid_retirement_contributions
  enum paid_school_supplies: { unfilled: 0, yes: 1, no: 2 }, _prefix: :paid_school_supplies
  enum paid_student_loan_interest: { unfilled: 0, yes: 1, no: 2 }, _prefix: :paid_student_loan_interest
  enum received_alimony: { unfilled: 0, yes: 1, no: 2 }, _prefix: :received_alimony
  enum received_homebuyer_credit: { unfilled: 0, yes: 1, no: 2 }, _prefix: :received_homebuyer_credit
  enum received_irs_letter: { unfilled: 0, yes: 1, no: 2 }, _prefix: :received_irs_letter
  enum reported_asset_sale_loss: { unfilled: 0, yes: 1, no: 2 }, _prefix: :reported_asset_sale_loss
  enum reported_self_employment_loss: { unfilled: 0, yes: 1, no: 2 }, _prefix: :reported_self_employment_loss
  enum separated: { unfilled: 0, yes: 1, no: 2 }, _prefix: :separated
  enum sold_a_home: { unfilled: 0, yes: 1, no: 2 }, _prefix: :sold_a_home
  enum widowed: { unfilled: 0, yes: 1, no: 2 }, _prefix: :widowed

  def primary_user
    users.where.not(is_spouse: true).first
  end

  def pdf
    IntakePdf.new(self).output_file
  end

  def greeting_name
    users.map(&:first_name).join(" and ")
  end

  def referrer_domain
    URI.parse(referrer).host if referrer.present?
  end
end
