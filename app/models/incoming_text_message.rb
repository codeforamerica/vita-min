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
#  index_incoming_text_messages_on_client_id  (client_id)
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
  validate :body_or_documents_present

  after_create { InteractionTrackingService.record_incoming_interaction(client) }

  def datetime
    received_at
  end

  def author
    client.preferred_name
  end

  def from
    Phonelib.parse(from_phone_number, "US").local_number
  end

  private

  def body_or_documents_present
    if documents.blank? && (body.nil? || body.size.zero?)
      errors.add(:body, "Can't be empty and have no documents")
    end
  end
end
