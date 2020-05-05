# == Schema Information
#
# Table name: states
#
#  abbreviation :string           not null, primary key
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_states_on_name  (name)
#
FactoryBot.define do
  factory :state do
    name { "MyString" }
    abbreviation { "MyString" }
  end
end
