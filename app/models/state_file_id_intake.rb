# == Schema Information
#
# Table name: state_file_id_intakes
#
#  id                                             :bigint           not null, primary key
#  account_number                                 :string
#  account_type                                   :integer          default("unfilled"), not null
#  bank_name                                      :string
#  consented_to_terms_and_conditions              :integer          default("unfilled"), not null
#  contact_preference                             :integer          default("unfilled"), not null
#  current_sign_in_at                             :datetime
#  current_sign_in_ip                             :inet
#  current_step                                   :string
#  date_electronic_withdrawal                     :date
#  df_data_import_failed_at                       :datetime
#  df_data_imported_at                            :datetime
#  donate_grocery_credit                          :integer          default(0), not null
#  eligibility_emergency_rental_assistance        :integer          default("unfilled"), not null
#  eligibility_withdrew_msa_fthb                  :integer          default("unfilled"), not null
#  email_address                                  :citext
#  email_address_verified_at                      :datetime
#  failed_attempts                                :integer          default(0), not null
#  federal_return_status                          :string
#  has_health_insurance_premium                   :integer          default(0), not null
#  has_unpaid_sales_use_tax                       :integer          default("unfilled"), not null
#  hashed_ssn                                     :string
#  health_insurance_paid_amount                   :decimal(12, 2)
#  household_has_grocery_credit_ineligible_months :integer          default(0), not null
#  last_sign_in_at                                :datetime
#  last_sign_in_ip                                :inet
#  locale                                         :string           default("en")
#  locked_at                                      :datetime
#  message_tracker                                :jsonb
#  payment_or_deposit_type                        :integer          default("unfilled"), not null
#  phone_number                                   :string
#  phone_number_verified_at                       :datetime
#  primary_birth_date                             :date
#  primary_esigned                                :integer          default("unfilled"), not null
#  primary_esigned_at                             :datetime
#  primary_first_name                             :string
#  primary_has_grocery_credit_ineligible_months   :integer          default(0), not null
#  primary_last_name                              :string
#  primary_middle_initial                         :string
#  primary_months_ineligible_for_grocery_credit   :integer          default(0)
#  primary_suffix                                 :string
#  raw_direct_file_data                           :text
#  raw_direct_file_intake_data                    :jsonb
#  referrer                                       :string
#  routing_number                                 :integer
#  sign_in_count                                  :integer          default(0), not null
#  source                                         :string
#  spouse_birth_date                              :date
#  spouse_esigned                                 :integer          default("unfilled"), not null
#  spouse_esigned_at                              :datetime
#  spouse_first_name                              :string
#  spouse_has_grocery_credit_ineligible_months    :integer          default(0), not null
#  spouse_last_name                               :string
#  spouse_middle_initial                          :string
#  spouse_months_ineligible_for_grocery_credit    :integer          default(0)
#  spouse_suffix                                  :string
#  total_purchase_amount                          :decimal(12, 2)
#  unsubscribed_from_email                        :boolean          default(FALSE), not null
#  withdraw_amount                                :integer
#  created_at                                     :datetime         not null
#  updated_at                                     :datetime         not null
#  federal_submission_id                          :string
#  visitor_id                                     :string
#
# Indexes
#
#  index_state_file_id_intakes_on_email_address  (email_address)
#  index_state_file_id_intakes_on_hashed_ssn     (hashed_ssn)
#

# Indexes
#
#  index_state_file_id_intakes_on_email_address  (email_address)
#  index_state_file_id_intakes_on_hashed_ssn     (hashed_ssn)
#
class StateFileIdIntake < StateFileBaseIntake
  enum eligibility_withdrew_msa_fthb: { unfilled: 0, yes: 1, no: 2 }, _prefix: :eligibility_withdrew_msa_fthb
  enum eligibility_emergency_rental_assistance: { unfilled: 0, yes: 1, no: 2 }, _prefix: :eligibility_emergency_rental_assistance
  enum has_unpaid_sales_use_tax: { unfilled: 0, yes: 1, no: 2 }, _prefix: :has_unpaid_sales_use_tax
  enum has_health_insurance_premium: { unfilled: 0, yes: 1, no: 2 }, _prefix: :has_health_insurance_premium

  def disqualifying_df_data_reason; end

  def disqualifying_eligibility_rules
    {
      eligibility_withdrew_msa_fthb: "yes",
      eligibility_emergency_rental_assistance: "yes"
    }
  end
end
