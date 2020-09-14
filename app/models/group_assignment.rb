# == Schema Information
#
# Table name: group_assignments
#
#  id             :bigint           not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  assigned_by_id :bigint
#  client_id      :bigint           not null
#  group_id       :bigint           not null
#
# Indexes
#
#  index_group_assignments_on_assigned_by_id  (assigned_by_id)
#  index_group_assignments_on_client_id       (client_id)
#  index_group_assignments_on_group_id        (group_id)
#
# Foreign Keys
#
#  fk_rails_...  (assigned_by_id => users.id)
#
class GroupAssignment < ApplicationRecord
  belongs_to :group
  belongs_to :client
end
