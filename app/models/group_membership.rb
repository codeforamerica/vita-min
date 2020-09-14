# == Schema Information
#
# Table name: group_memberships
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  added_by_id :bigint
#  group_id    :bigint           not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_group_memberships_on_added_by_id  (added_by_id)
#  index_group_memberships_on_group_id     (group_id)
#  index_group_memberships_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (added_by_id => users.id)
#
class GroupMembership < ApplicationRecord
  belongs_to :group
  belongs_to :user
end
