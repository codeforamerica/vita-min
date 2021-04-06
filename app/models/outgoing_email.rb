# == Schema Information
#
# Table name: outgoing_emails
#
#  id             :bigint           not null, primary key
#  body           :string           not null
#  mailgun_status :string
#  sent_at        :datetime         not null
#  subject        :string           not null
#  to             :citext           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  client_id      :bigint           not null
#  mailgun_id     :string
#  user_id        :bigint
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
  # has_one_attached needs to be called after defining any callbacks that access attachments, like :deliver; see https://github.com/rails/rails/issues/37304
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
    SendOutgoingEmailJob.perform_later(id)
  end

  def broadcast
    ClientChannel.broadcast_contact_record(self)
  end
end
