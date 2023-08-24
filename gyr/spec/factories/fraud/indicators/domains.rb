# == Schema Information
#
# Table name: fraud_indicators_domains
#
#  id           :bigint           not null, primary key
#  activated_at :datetime
#  name         :string
#  risky        :boolean
#  safe         :boolean
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_fraud_indicators_domains_on_risky  (risky)
#  index_fraud_indicators_domains_on_safe   (safe)
#
FactoryBot.define do
  factory :safe_domain, class: "Fraud::Indicators::Domain" do
    name { "gmail.com" }
    safe { true }
    activated_at { DateTime.now }
  end

  factory :risky_domain, class: "Fraud::Indicators::Domain" do
    name { "fraud.com" }
    risky { true }
    activated_at { DateTime.now }
  end
end
