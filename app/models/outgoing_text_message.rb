# == Schema Information
#
# Table name: outgoing_text_messages
#
#  id              :bigint           not null, primary key
#  body            :string           not null
#  sent_at         :datetime         not null
#  to_phone_number :string           not null
#  twilio_sid      :string
#  twilio_status   :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  client_id       :bigint           not null
#  user_id         :bigint
#
# Indexes
#
#  index_outgoing_text_messages_on_client_id  (client_id)
#  index_outgoing_text_messages_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (user_id => users.id)
#
class OutgoingTextMessage < ApplicationRecord
  include ContactRecord
  include InteractionTracking

  belongs_to :client
  belongs_to :user, optional: true
  validates_presence_of :body
  validates_presence_of :sent_at
  validates :to_phone_number, e164_phone: true

  after_create :deliver, :broadcast
  after_create :record_outgoing_interaction, if: ->(msg) { msg.user.present? }

  def datetime
    sent_at
  end

  def author
    user&.name
  end

  def documents
    []
  end

  def to
    Phonelib.parse(to_phone_number, "US").local_number
  end

  private

  def deliver
    SendOutgoingTextMessageJob.perform_later(id)
  end

  def broadcast
    ClientChannel.broadcast_contact_record(self)
  end
end
