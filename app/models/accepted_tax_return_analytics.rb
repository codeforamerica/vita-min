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

  def calculated_benefits_attrs
    benefits = Efile::BenefitsEligibility.new(tax_return: tax_return, dependents: tax_return.qualifying_dependents)
    eip1_and_eip2_amount = [benefits.eip1_amount, benefits.eip2_amount].compact.sum
    total_refund_amount = [benefits.outstanding_ctc_amount, benefits.outstanding_recovery_rebate_credit].compact.sum

    { eip1_and_eip2_amount_cents: eip1_and_eip2_amount * 100,
      advance_ctc_amount_cents: benefits.advance_ctc_amount_received * 100,
      outstanding_ctc_amount_cents: benefits.outstanding_ctc_amount * 100,
      ctc_amount_cents: benefits.ctc_amount * 100,
      eip3_amount_received_cents: benefits.eip3_amount_received * 100,
      eip3_amount_cents: benefits.eip3_amount * 100,
      outstanding_eip3_amount_cents: benefits.outstanding_eip3 * 100,
      total_refund_amount_cents: total_refund_amount * 100 }
  end
end
