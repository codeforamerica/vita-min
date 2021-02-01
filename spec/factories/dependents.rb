# == Schema Information
#
# Table name: dependents
#
#  id                      :bigint           not null, primary key
#  birth_date              :date
#  disabled                :integer          default("unfilled"), not null
#  first_name              :string
#  last_name               :string
#  months_in_home          :integer
#  north_american_resident :integer          default("unfilled"), not null
#  on_visa                 :integer          default("unfilled"), not null
#  relationship            :string
#  was_married             :integer          default("unfilled"), not null
#  was_student             :integer          default("unfilled"), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  intake_id               :bigint           not null
#
# Indexes
#
#  index_dependents_on_intake_id  (intake_id)
#

FactoryBot.define do
  factory :dependent do
    intake
    first_name { "Kara" }
    last_name { "Kiwi" }
    birth_date { Date.new(2011, 3, 5) }
    relationship { "child" }
    north_american_resident { "yes" }
    on_visa { "no" }
    months_in_home { 11 }
    was_married { "no" }
    was_student { "yes" }
    disabled { "no" }
  end
end
