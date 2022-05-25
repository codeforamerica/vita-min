# == Schema Information
#
# Table name: accepted_tax_return_analytics
#
#  id                            :bigint           not null, primary key
#  advance_ctc_amount_cents      :bigint
#  ctc_amount_cents              :bigint
#  eip1_and_eip2_amount_cents    :bigint
#  eip3_amount_cents             :bigint
#  eip3_amount_received_cents    :bigint
#  outstanding_ctc_amount_cents  :bigint
#  outstanding_eip3_amount_cents :bigint
#  tax_return_year               :integer
#  total_refund_amount_cents     :bigint
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  tax_return_id                 :bigint
#
# Indexes
#
#  index_accepted_tax_return_analytics_on_tax_return_id  (tax_return_id)
#
class AcceptedTaxReturnAnalytics < ApplicationRecord
  belongs_to :tax_return
end
