# == Schema Information
#
# Table name: state_routing_targets
#
#  id                 :bigint           not null, primary key
#  state_abbreviation :string           not null
#  target_type        :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  target_id          :bigint           not null
#
# Indexes
#
#  index_state_routing_targets_on_target  (target_type,target_id)
#
FactoryBot.define do
  factory :state_routing_target do
    target { build :organization }
  end
end
