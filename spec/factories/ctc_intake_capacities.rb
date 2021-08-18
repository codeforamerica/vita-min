# == Schema Information
#
# Table name: ctc_intake_capacities
#
#  id         :bigint           not null, primary key
#  capacity   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_ctc_intake_capacities_on_created_at  (created_at)
#  index_ctc_intake_capacities_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :ctc_intake_capacity do
    capacity { 100 }
    user { build(:admin_user) }
  end
end
