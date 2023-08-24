# == Schema Information
#
# Table name: timezone_indicators
#
#  id           :bigint           not null, primary key
#  activated_at :datetime
#  name         :string
#  override     :boolean          default(TRUE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
FactoryBot.define do
  factory :timezone_indicator, class: Fraud::Indicators::Timezone do
    name { "America/Chicago" }
    activated_at { DateTime.now }
  end
end
