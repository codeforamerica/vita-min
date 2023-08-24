# == Schema Information
#
# Table name: w2_box14s
#
#  id                :bigint           not null, primary key
#  other_amount      :decimal(12, 2)
#  other_description :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  w2_id             :bigint           not null
#
# Indexes
#
#  index_w2_box14s_on_w2_id  (w2_id)
#
# Foreign Keys
#
#  fk_rails_...  (w2_id => w2s.id)
#
FactoryBot.define do
  factory :w2_box14 do
    w2
  end
end
