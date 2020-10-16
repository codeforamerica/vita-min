# == Schema Information
#
# Table name: clients
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :client do
    intake

    trait :filled_out do
      intake { create :intake, :filled_out }
    end
  end
end
