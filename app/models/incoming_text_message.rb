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

  belongs_to :client
  has_many :documents, as: :contact_record

  validates_presence_of :received_at, :body
  validates :from_phone_number, presence: true, phone: true, format: { with: /\+1[0-9]{10}/ }

  after_create :record_incoming_interaction

  def datetime
    received_at
  end

  def author
    client.preferred_name
  end
end
