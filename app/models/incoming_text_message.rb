# == Schema Information
#
# Table name: incoming_text_messages
#
#  id                :bigint           not null, primary key
#  body              :string           not null
#  from_phone_number :string           not null
#  received_at       :datetime         not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  client_id         :bigint           not null
#
# Indexes
#
#  index_incoming_text_messages_on_client_id  (client_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#
class IncomingTextMessage < ApplicationRecord
  include ContactRecord
  include InteractionTracking

  has_many_attached :documents
  alias_method :attachments, :documents
  belongs_to :client
  validates_presence_of :body
  validates_presence_of :received_at

  after_create :record_incoming_interaction

  def datetime
    received_at
  end

  def author
    client.preferred_name
  end
end
