# == Schema Information
#
# Table name: coalitions
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_coalitions_on_name  (name) UNIQUE
#
FactoryBot.define do
  factory :coalition do
    sequence(:name) { |n| "Coalition #{n}" }
  end
end
