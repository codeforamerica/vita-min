# == Schema Information
#
# Table name: outgoing_emails
#
#  id         :bigint           not null, primary key
#  body       :string           not null
#  sent_at    :datetime         not null
#  subject    :string           not null
#  to         :citext           not null
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
  # Use `after_create_commit` so that the attachment is fully saved to S3 before delivering it
  after_create_commit :deliver, :broadcast
  after_create_commit :record_outgoing_interaction, if: ->(email) { email.user.present? }
  # Use `has_one_attached` below `after_create_commit`; ActiveRecord runs callbacks in last-in, first-out order
  # See also https://github.com/rails/rails/issues/37304#issuecomment-546246357
  has_one_attached :attachment

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
