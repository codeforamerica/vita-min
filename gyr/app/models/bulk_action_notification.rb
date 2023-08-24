# == Schema Information
#
# Table name: bulk_action_notifications
#
#  id                      :bigint           not null, primary key
#  task_type               :string           not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  tax_return_selection_id :bigint           not null
#
# Indexes
#
#  index_bulk_action_notifications_on_tax_return_selection_id  (tax_return_selection_id)
#
# Foreign Keys
#
#  fk_rails_...  (tax_return_selection_id => tax_return_selections.id)
#
class BulkActionNotification < ApplicationRecord
  has_one :user_notification, as: :notifiable, dependent: :destroy
  belongs_to :tax_return_selection
  validates_presence_of :task_type
end
