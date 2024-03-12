# == Schema Information
#
# Table name: state_file_analytics
#
#  id                        :bigint           not null, primary key
#  dependent_tax_credit      :integer
#  empire_state_child_credit :integer
#  excise_credit             :integer
#  family_income_tax_credit  :integer
#  fed_eitc_amount           :integer
#  filing_status             :integer
#  household_fed_agi         :integer
#  nyc_eitc                  :integer
#  nyc_household_credit      :integer
#  nyc_school_tax_credit     :integer
#  nys_eitc                  :integer
#  nys_household_credit      :integer
#  record_type               :string           not null
#  refund_or_owed_amount     :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  record_id                 :bigint           not null
#
# Indexes
#
#  index_state_file_analytics_on_record  (record_type,record_id)
#
class StateFileAnalytics < ApplicationRecord
  belongs_to :record, polymorphic: true
  before_create :calculated_attrs

  def calculated_attrs
    attributes = {
      fed_eitc_amount: record.direct_file_data.fed_eic,
      filing_status: record.direct_file_data.filing_status,
      refund_or_owed_amount: record.calculated_refund_or_owed_amount,
      household_fed_agi: record.direct_file_data.fed_agi
    }
    attributes.merge!(record.calculator&.analytics_attrs || {})
    assign_attributes(attributes)
  end
end
