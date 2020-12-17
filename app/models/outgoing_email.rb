# == Schema Information
#
# Table name: outgoing_emails
#
#  id         :bigint           not null, primary key
#  body       :string           not null
#  sent_at    :datetime         not null
#  subject    :string           not null
#  to         :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  client_id  :bigint           not null
#  user_id    :bigint
#
# Indexes
#
#  index_outgoing_emails_on_client_id  (client_id)
#  index_outgoing_emails_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (user_id => users.id)
#
class OutgoingEmail < ApplicationRecord
  include ContactRecord
  include InteractionTracking

  belongs_to :client
  belongs_to :user, optional: true
  validates_presence_of :to
  validates_presence_of :body
  validates_presence_of :subject
  validates_presence_of :sent_at
  has_one_attached :attachment

  after_create :record_outgoing_interaction, :deliver, :broadcast

  def datetime
    sent_at
  end

  def author
    user&.name
  end

  def attachments
    attachment.present? ? [attachment] : nil
  end

  private

  def deliver
    OutgoingEmailMailer.user_message(outgoing_email: self).deliver_later
  end

  def broadcast
    ClientChannel.broadcast_contact_record(self)
  end
end
