# == Schema Information
#
# Table name: state_file_analytics
#
#  id                                            :bigint           not null, primary key
#  az_credit_for_contributions_to_public_schools :integer
#  az_credit_for_contributions_to_qcos           :integer
#  az_pension_exclusion_government               :integer
#  az_pension_exclusion_uniformed_services       :integer
#  canceled_data_transfer_count                  :integer          default(0)
#  dependent_tax_credit                          :integer
#  empire_state_child_credit                     :integer
#  excise_credit                                 :integer
#  family_income_tax_credit                      :integer
#  fed_eitc_amount                               :integer
#  fed_refund_amt                                :integer
#  filing_status                                 :integer
#  household_fed_agi                             :integer
#  id_retirement_benefits_deduction              :integer
#  initiate_data_transfer_first_visit_at         :datetime
#  initiate_df_data_transfer_clicks              :integer          default(0)
#  md_child_dep_care_credit                      :integer
#  md_child_dep_care_subtraction                 :integer
#  md_ctc                                        :integer
#  md_eic                                        :integer
#  md_income_us_gov_subtraction                  :integer
#  md_local_eic                                  :integer
#  md_local_poverty_credit                       :integer
#  md_military_retirement_subtraction            :integer
#  md_poverty_credit                             :integer
#  md_primary_pension_exclusion                  :integer
#  md_public_safety_subtraction                  :integer
#  md_refundable_child_dep_care_credit           :integer
#  md_refundable_eic                             :integer
#  md_senior_tax_credit                          :integer
#  md_spouse_pension_exclusion                   :integer
#  md_ssa_benefits_subtraction                   :integer
#  md_stpickup_addition                          :integer
#  md_total_pension_exclusion                    :integer
#  md_two_income_subtraction                     :integer
#  name_dob_first_visit_at                       :datetime
#  nc_retirement_benefits_bailey                 :integer
#  nc_retirement_benefits_uniformed_services     :integer
#  nyc_eitc                                      :integer
#  nyc_household_credit                          :integer
#  nyc_school_tax_credit                         :integer
#  nys_eitc                                      :integer
#  nys_household_credit                          :integer
#  record_type                                   :string           not null
#  refund_or_owed_amount                         :integer
#  zip_code                                      :string
#  created_at                                    :datetime         not null
#  updated_at                                    :datetime         not null
#  record_id                                     :bigint           not null
#
# Indexes
#
#  index_state_file_analytics_on_record  (record_type,record_id)
#
class StateFileAnalytics < ApplicationRecord
  belongs_to :record, polymorphic: true

  def calculated_attrs
    attributes = {
      fed_eitc_amount: record.direct_file_data.fed_eic,
      filing_status: record.direct_file_data.filing_status,
      fed_refund_amt: record.direct_file_data.fed_refund_amt, # federal amount
      refund_or_owed_amount: record.calculated_refund_or_owed_amount, # state amount
      household_fed_agi: record.direct_file_data.fed_agi,
      zip_code: record.direct_file_data.mailing_zip
    }
    attributes.merge!(record.calculator&.analytics_attrs || {})
  end
end
