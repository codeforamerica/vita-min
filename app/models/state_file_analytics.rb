# == Schema Information
#
# Table name: state_file_analytics
#
#  id                                    :bigint           not null, primary key
#  canceled_data_transfer_count          :integer          default(0)
#  dependent_tax_credit                  :integer
#  empire_state_child_credit             :integer
#  excise_credit                         :integer
#  family_income_tax_credit              :integer
#  fed_eitc_amount                       :integer
#  fed_refund_amt                        :integer
#  filing_status                         :integer
#  household_fed_agi                     :integer
#  initiate_data_transfer_first_visit_at :datetime
#  initiate_df_data_transfer_clicks      :integer          default(0)
#  name_dob_first_visit_at               :datetime
#  nyc_eitc                              :integer
#  nyc_household_credit                  :integer
#  nyc_school_tax_credit                 :integer
#  nys_eitc                              :integer
#  nys_household_credit                  :integer
#  record_type                           :string           not null
#  refund_or_owed_amount                 :integer
#  zip_code                              :string
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#  record_id                             :bigint           not null
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
