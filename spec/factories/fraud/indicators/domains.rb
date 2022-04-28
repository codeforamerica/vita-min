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