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
require 'rails_helper'

describe AcceptedTaxReturnAnalytics do
  describe "#calculated_benefits_attrs" do
    before do
      allow_any_instance_of(Efile::BenefitsEligibility).to receive(:eip1_amount).and_return(1000)
      allow_any_instance_of(Efile::BenefitsEligibility).to receive(:eip2_amount).and_return(1300)
      allow_any_instance_of(Efile::BenefitsEligibility).to receive(:eip3_amount).and_return(2400)
      allow_any_instance_of(Efile::BenefitsEligibility).to receive(:eip3_amount_received).and_return(2350)
      allow_any_instance_of(Efile::BenefitsEligibility).to receive(:outstanding_eip3).and_return(450)
      allow_any_instance_of(Efile::BenefitsEligibility).to receive(:ctc_amount).and_return(2450)
      allow_any_instance_of(Efile::BenefitsEligibility).to receive(:advance_ctc_amount_received).and_return(1500)
      allow_any_instance_of(Efile::BenefitsEligibility).to receive(:outstanding_ctc_amount).and_return(900)
      allow_any_instance_of(Efile::BenefitsEligibility).to receive(:outstanding_recovery_rebate_credit).and_return(2400)
    end

    let!(:accepted_tax_return_analytics) { create :accepted_tax_return_analytics, tax_return: create(:tax_return, :ctc) }

    it 'returns the calculated attributes' do
      expected_attributes = {
        outstanding_ctc_amount_cents: 90000,
        ctc_amount_cents: 245000,
        advance_ctc_amount_cents: 150000,
        eip1_and_eip2_amount_cents: 230000,
        outstanding_eip3_amount_cents: 45000,
        eip3_amount_cents: 240000,
        eip3_amount_received_cents: 235000,
        total_refund_amount_cents: 330000
      }

      expect(accepted_tax_return_analytics.calculated_benefits_attrs).to eq expected_attributes
    end
  end
end
