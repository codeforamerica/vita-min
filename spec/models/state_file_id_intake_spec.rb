# == Schema Information
#
# Table name: state_file_id_intakes
#
#  id                                             :bigint           not null, primary key
#  account_number                                 :string
#  account_type                                   :integer          default("unfilled"), not null
#  american_red_cross_fund_donation               :decimal(12, 2)
#  bank_name                                      :string
#  childrens_trust_fund_donation                  :decimal(12, 2)
#  consented_to_terms_and_conditions              :integer          default("unfilled"), not null
#  contact_preference                             :integer          default("unfilled"), not null
#  current_sign_in_at                             :datetime
#  current_sign_in_ip                             :inet
#  current_step                                   :string
#  date_electronic_withdrawal                     :date
#  df_data_import_failed_at                       :datetime
#  df_data_import_succeeded_at                    :datetime
#  df_data_imported_at                            :datetime
#  donate_grocery_credit                          :integer          default("unfilled"), not null
#  eligibility_emergency_rental_assistance        :integer          default("unfilled"), not null
#  eligibility_withdrew_msa_fthb                  :integer          default("unfilled"), not null
#  email_address                                  :citext
#  email_address_verified_at                      :datetime
#  failed_attempts                                :integer          default(0), not null
#  federal_return_status                          :string
#  food_bank_fund_donation                        :decimal(12, 2)
#  guard_reserve_family_donation                  :decimal(12, 2)
#  has_health_insurance_premium                   :integer          default("unfilled"), not null
#  has_unpaid_sales_use_tax                       :integer          default("unfilled"), not null
#  hashed_ssn                                     :string
#  health_insurance_paid_amount                   :decimal(12, 2)
#  household_has_grocery_credit_ineligible_months :integer          default("unfilled"), not null
#  last_sign_in_at                                :datetime
#  last_sign_in_ip                                :inet
#  locale                                         :string           default("en")
#  locked_at                                      :datetime
#  message_tracker                                :jsonb
#  nongame_wildlife_fund_donation                 :decimal(12, 2)
#  opportunity_scholarship_program_donation       :decimal(12, 2)
#  payment_or_deposit_type                        :integer          default("unfilled"), not null
#  phone_number                                   :string
#  phone_number_verified_at                       :datetime
#  primary_birth_date                             :date
#  primary_esigned                                :integer          default("unfilled"), not null
#  primary_esigned_at                             :datetime
#  primary_first_name                             :string
#  primary_has_grocery_credit_ineligible_months   :integer          default("unfilled"), not null
#  primary_last_name                              :string
#  primary_middle_initial                         :string
#  primary_months_ineligible_for_grocery_credit   :integer
#  primary_suffix                                 :string
#  raw_direct_file_data                           :text
#  raw_direct_file_intake_data                    :jsonb
#  received_id_public_assistance                  :integer          default("unfilled"), not null
#  referrer                                       :string
#  routing_number                                 :string
#  sign_in_count                                  :integer          default(0), not null
#  source                                         :string
#  special_olympics_donation                      :decimal(12, 2)
#  spouse_birth_date                              :date
#  spouse_esigned                                 :integer          default("unfilled"), not null
#  spouse_esigned_at                              :datetime
#  spouse_first_name                              :string
#  spouse_has_grocery_credit_ineligible_months    :integer          default("unfilled"), not null
#  spouse_last_name                               :string
#  spouse_middle_initial                          :string
#  spouse_months_ineligible_for_grocery_credit    :integer
#  spouse_suffix                                  :string
#  total_purchase_amount                          :decimal(12, 2)
#  unsubscribed_from_email                        :boolean          default(FALSE), not null
#  veterans_support_fund_donation                 :decimal(12, 2)
#  withdraw_amount                                :integer
#  created_at                                     :datetime         not null
#  updated_at                                     :datetime         not null
#  federal_submission_id                          :string
#  primary_state_id_id                            :bigint
#  spouse_state_id_id                             :bigint
#  visitor_id                                     :string
#
# Indexes
#
#  index_state_file_id_intakes_on_email_address        (email_address)
#  index_state_file_id_intakes_on_hashed_ssn           (hashed_ssn)
#  index_state_file_id_intakes_on_primary_state_id_id  (primary_state_id_id)
#  index_state_file_id_intakes_on_spouse_state_id_id   (spouse_state_id_id)
#
require 'rails_helper'

RSpec.describe StateFileIdIntake, type: :model do
  it_behaves_like :state_file_base_intake, factory: :state_file_id_intake
end
