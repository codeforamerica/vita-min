# == Schema Information
#
# Table name: tax_return_analytics
#
#  id                       :bigint           not null, primary key
#  advance_ctc_amount_cents :bigint
#  eip3_amount_cents        :bigint
#  refund_amount_cents      :bigint
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  tax_return_id            :bigint
#
# Indexes
#
#  index_tax_return_analytics_on_tax_return_id  (tax_return_id)
#
FactoryBot.define do
  factory :tax_return_analytic do
    
  end
end
