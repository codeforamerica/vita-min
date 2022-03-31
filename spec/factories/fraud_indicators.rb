# == Schema Information
#
# Table name: fraud_indicators
#
#  id                   :bigint           not null, primary key
#  activated_at         :datetime
#  description          :text
#  indicator_attributes :string           default([]), is an Array
#  indicator_type       :string
#  list_model_name      :string
#  multiplier           :float
#  name                 :string
#  points               :integer
#  query_model_name     :string
#  reference            :string
#  threshold            :float
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
FactoryBot.define do
  factory :duplicate_fraud_indicator, class: Fraud::Indicator do
    name { "primary_name_used_multiple_times" }
    indicator_type { :duplicates }
    multiplier { 0.125 }
    threshold { 1 }
    points { 60 }
    query_model_name { Intake }
    reference { "intake" }
    indicator_attributes { ["primary_first_name"] }
  end
end
