# == Schema Information
#
# Table name: incoming_text_messages
#
#  id                :bigint           not null, primary key
#  body              :string
#  from_phone_number :string           not null
#  received_at       :datetime         not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  client_id         :bigint           not null
#
# Indexes
#
#  index_incoming_text_messages_on_client_id   (client_id)
#  index_incoming_text_messages_on_created_at  (created_at)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#
class IncomingTextMessage < ApplicationRecord
  include ContactRecord

  belongs_to :client
  has_many :documents, as: :contact_record
  validates_presence_of :received_at
  validates :from_phone_number, presence: true, e164_phone: true

  after_create { InteractionTrackingService.record_incoming_interaction(client) }

  def datetime
    received_at
  end

  def from
    PhoneParser.formatted_phone_number(from_phone_number)
  end

  def body
    raw_body = attributes["body"]

    if raw_body.blank? && documents.blank?
      "Client sent an empty text message with no attachments"
    else
      raw_body
    end
  end
end
