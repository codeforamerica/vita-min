# == Schema Information
#
# Table name: state_file_analytics
#
#  id                    :bigint           not null, primary key
#  fed_eitc_amount       :integer
#  filing_status         :integer
#  record_type           :string           not null
#  refund_or_owed_amount :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  record_id             :bigint           not null
#
# Indexes
#
#  index_state_file_analytics_on_record  (record_type,record_id)
#
class StateFileAnalytics < ApplicationRecord
  belongs_to :record, polymorphic: true
  before_create :calculated_attrs

  def calculated_attrs
    assign_attributes({
      fed_eitc_amount: record.direct_file_data.fed_eic,
      filing_status: record.direct_file_data.filing_status,
      refund_or_owed_amount: record.calculated_refund_or_owed_amount
    })
  end
end
