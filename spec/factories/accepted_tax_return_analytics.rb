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
FactoryBot.define do
  factory :accepted_tax_return_analytics do
    trait :with_tax_return do
      tax_return { create(:tax_return, year: 2021) }
      outstanding_ctc_amount_cents { 90000 }
      ctc_amount_cents { 245000 }
      advance_ctc_amount_cents { 150000 }
      eip1_and_eip2_amount_cents { 230000 }
      eip3_amount_cents { 240000 }
      eip3_amount_received_cents { 235000 }
      tax_return_year { 2021 }
      total_refund_amount_cents { 330000 }
    end
  end
end
