# == Schema Information
#
# Table name: bulk_action_notifications
#
#  id         :bigint           not null, primary key
#  task_type  :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class BulkActionNotification < ApplicationRecord
  has_one :user_notification, as: :notifiable
  belongs_to :tax_return_selection
end
