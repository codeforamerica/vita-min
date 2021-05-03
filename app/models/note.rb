# == Schema Information
#
# Table name: notes
#
#  id         :bigint           not null, primary key
#  body       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  client_id  :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_notes_on_client_id  (client_id)
#  index_notes_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (user_id => users.id)
#
class Note < ApplicationRecord
  belongs_to :user
  belongs_to :client
  validates_presence_of :body

  has_many :user_notifications, as: :notifiable, dependent: :destroy

  after_save { InteractionTrackingService.record_internal_interaction(client) }
end
