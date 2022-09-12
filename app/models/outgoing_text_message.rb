# == Schema Information
#
# Table name: outgoing_text_messages
#
#  id              :bigint           not null, primary key
#  body            :string           not null
#  sent_at         :datetime
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
#  index_outgoing_text_messages_on_client_id   (client_id)
#  index_outgoing_text_messages_on_created_at  (created_at)
#  index_outgoing_text_messages_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (user_id => users.id)
#
class OutgoingTextMessage < ApplicationRecord
  include ContactRecord

  FAILED_TWILIO_STATUSES = ["undelivered", "failed", "delivery_unknown", "twilio_error"].freeze
  SUCCESSFUL_TWILIO_STATUSES = ["sent", "delivered"].freeze
  IN_PROGRESS_TWILIO_STATUSES = ["accepted", "queued", "sending", nil].freeze
  ALL_KNOWN_TWILIO_STATUSES = FAILED_TWILIO_STATUSES + SUCCESSFUL_TWILIO_STATUSES + IN_PROGRESS_TWILIO_STATUSES

  # https://support.twilio.com/hc/en-us/articles/223134347-What-are-the-Possible-SMS-and-MMS-Message-Statuses-and-What-do-They-Mean-
  ORDERED_STATUSES = [nil, "twilio_error"] + %w(
    queued
    accepted
    sending
    sent
    delivery_unknown
    delivered
    undelivered
    failed
  ).freeze

  belongs_to :client
  belongs_to :user, optional: true
  has_many :bulk_client_message_outgoing_text_messages, dependent: :destroy
  validates_presence_of :body
  validates :to_phone_number, e164_phone: true
  validates :twilio_status, inclusion: { in: ALL_KNOWN_TWILIO_STATUSES }
  after_create :deliver, :broadcast
  after_create { |msg| InteractionTrackingService.record_user_initiated_outgoing_interaction(client) if msg.user.present? }
  after_create { InteractionTrackingService.update_last_outgoing_communication_at(client) }
  scope :succeeded, -> { where(twilio_status: SUCCESSFUL_TWILIO_STATUSES) }
  scope :failed, -> { where(twilio_status: FAILED_TWILIO_STATUSES) }
  scope :in_progress, -> { where(twilio_status: IN_PROGRESS_TWILIO_STATUSES) }

  def datetime
    sent_at || created_at
  end

  def documents
    []
  end

  def to
    PhoneParser.formatted_phone_number(to_phone_number)
  end

  def update_status_if_further(new_status)
    with_lock do
      old_index = ORDERED_STATUSES.index(twilio_status)
      new_index = ORDERED_STATUSES.index(new_status)

      if new_index > old_index
        update(twilio_status: new_status)
      end
    end
  end

  private

  def deliver
    SendOutgoingTextMessageJob.perform_later(id)
  end

  def broadcast
    ClientChannel.broadcast_contact_record(self)
  end
end
