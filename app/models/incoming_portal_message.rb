# == Schema Information
#
# Table name: incoming_portal_messages
#
#  id         :bigint           not null, primary key
#  body       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  client_id  :bigint
#
# Indexes
#
#  index_incoming_portal_messages_on_client_id   (client_id)
#  index_incoming_portal_messages_on_created_at  (created_at)
#
class IncomingPortalMessage < ApplicationRecord
  include ContactRecord

  belongs_to :client

  after_create do
    InteractionTrackingService.record_incoming_interaction(client, message_received_at: datetime, interaction_type: :client_message)
  end
  validates :body, presence: true

  def datetime
    created_at
  end
end
