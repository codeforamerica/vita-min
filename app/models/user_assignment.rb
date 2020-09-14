# == Schema Information
#
# Table name: user_assignments
#
#  id             :bigint           not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  assigned_by_id :bigint
#  client_id      :bigint           not null
#  user_id        :bigint           not null
#
# Indexes
#
#  index_user_assignments_on_assigned_by_id  (assigned_by_id)
#  index_user_assignments_on_client_id       (client_id)
#  index_user_assignments_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (assigned_by_id => users.id)
#
class UserAssignment < ApplicationRecord
  has_one :user
  has_one :client
end
