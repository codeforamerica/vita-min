# == Schema Information
#
# Table name: signup_selections
#
#  id          :bigint           not null, primary key
#  filename    :text             not null
#  id_array    :integer          not null, is an Array
#  signup_type :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :bigint
#
# Indexes
#
#  index_signup_selections_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :signup_selection do
    filename { "example.csv" }
    id_array { [3, 4, 5] }
    signup_type { "GYR" }
    user { build(:admin_user) }
  end
end
