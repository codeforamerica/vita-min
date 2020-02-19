# == Schema Information
#
# Table name: intakes
#
#  id                                                   :bigint           not null, primary key
#  additional_info                                      :string
#  adopted_child                                        :integer          default("unfilled"), not null
#  bought_health_insurance                              :integer          default("unfilled"), not null
#  city                                                 :string
#  demographic_disability                               :integer          default("unfilled"), not null
#  demographic_english_conversation                     :integer          default("unfilled"), not null
#  demographic_english_reading                          :integer          default("unfilled"), not null
#  demographic_primary_american_indian_alaska_native    :boolean
#  demographic_primary_asian                            :boolean
#  demographic_primary_black_africa_american            :boolean
#  demographic_primary_ethnicity                        :integer          default("unfilled"), not null
#  demographic_primary_native_hawaiian_pacific_islander :boolean
#  demographic_primary_prefer_not_to_answer_race        :boolean
#  demographic_primary_white                            :boolean
#  demographic_questions_opt_in                         :integer          default("unfilled"), not null
#  demographic_spouse_american_indian_alaska_native     :boolean
#  demographic_spouse_asian                             :boolean
#  demographic_spouse_black_africa_american             :boolean
#  demographic_spouse_ethnicity                         :integer          default("unfilled"), not null
#  demographic_spouse_native_hawaiian_pacific_islander  :boolean
#  demographic_spouse_prefer_not_to_answer_race         :boolean
#  demographic_spouse_white                             :boolean
#  demographic_veteran                                  :integer          default("unfilled"), not null
#  divorced                                             :integer          default("unfilled"), not null
#  divorced_year                                        :string
#  ever_married                                         :integer          default("unfilled"), not null
#  filing_joint                                         :integer          default("unfilled"), not null
#  had_asset_sale_income                                :integer          default("unfilled"), not null
#  had_debt_forgiven                                    :integer          default("unfilled"), not null
#  had_dependents                                       :integer          default("unfilled"), not null
#  had_disability_income                                :integer          default("unfilled"), not null
#  had_disaster_loss                                    :integer          default("unfilled"), not null
#  had_farm_income                                      :integer          default("unfilled"), not null
#  had_gambling_income                                  :integer          default("unfilled"), not null
#  had_hsa                                              :integer          default("unfilled"), not null
#  had_interest_income                                  :integer          default("unfilled"), not null
#  had_local_tax_refund                                 :integer          default("unfilled"), not null
#  had_other_income                                     :integer          default("unfilled"), not null
#  had_rental_income                                    :integer          default("unfilled"), not null
#  had_retirement_income                                :integer          default("unfilled"), not null
#  had_self_employment_income                           :integer          default("unfilled"), not null
#  had_social_security_income                           :integer          default("unfilled"), not null
#  had_student_in_family                                :integer          default("unfilled"), not null
#  had_tax_credit_disallowed                            :integer          default("unfilled"), not null
#  had_tips                                             :integer          default("unfilled"), not null
#  had_unemployment_income                              :integer          default("unfilled"), not null
#  had_wages                                            :integer          default("unfilled"), not null
#  intake_pdf_sent_to_zendesk                           :boolean          default(FALSE), not null
#  interview_timing_preference                          :string
#  job_count                                            :integer
#  lived_with_spouse                                    :integer          default("unfilled"), not null
#  made_estimated_tax_payments                          :integer          default("unfilled"), not null
#  married                                              :integer          default("unfilled"), not null
#  other_income_types                                   :string
#  paid_alimony                                         :integer          default("unfilled"), not null
#  paid_charitable_contributions                        :integer          default("unfilled"), not null
#  paid_dependent_care                                  :integer          default("unfilled"), not null
#  paid_local_tax                                       :integer          default("unfilled"), not null
#  paid_medical_expenses                                :integer          default("unfilled"), not null
#  paid_mortgage_interest                               :integer          default("unfilled"), not null
#  paid_retirement_contributions                        :integer          default("unfilled"), not null
#  paid_school_supplies                                 :integer          default("unfilled"), not null
#  paid_student_loan_interest                           :integer          default("unfilled"), not null
#  received_alimony                                     :integer          default("unfilled"), not null
#  received_homebuyer_credit                            :integer          default("unfilled"), not null
#  received_irs_letter                                  :integer          default("unfilled"), not null
#  referrer                                             :string
#  reported_asset_sale_loss                             :integer          default("unfilled"), not null
#  reported_self_employment_loss                        :integer          default("unfilled"), not null
#  separated                                            :integer          default("unfilled"), not null
#  separated_year                                       :string
#  sold_a_home                                          :integer          default("unfilled"), not null
#  source                                               :string
#  state                                                :string
#  street_address                                       :string
#  widowed                                              :integer          default("unfilled"), not null
#  widowed_year                                         :string
#  zip_code                                             :string
#  created_at                                           :datetime
#  updated_at                                           :datetime
#  intake_ticket_id                                     :bigint
#  intake_ticket_requester_id                           :bigint
#

FactoryBot.define do
  factory :intake do
    had_wages { :unfilled }
  end
end
