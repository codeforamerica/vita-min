# == Schema Information
#
# Table name: bulk_client_messages
#
#  id                  :bigint           not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  client_selection_id :bigint           not null
#
# Indexes
#
#  index_bulk_client_messages_on_client_selection_id  (client_selection_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_selection_id => client_selections.id)
#
class BulkClientMessage < ApplicationRecord
  has_one :user_notification, as: :notifiable
  belongs_to :client_selection
  has_many :bulk_client_message_outgoing_emails
  has_many :bulk_client_message_outgoing_text_messages
  has_many :outgoing_emails, through: :bulk_client_message_outgoing_emails
  has_many :outgoing_text_messages, through: :bulk_client_message_outgoing_text_messages

  SUCCEEDED = "succeeded".freeze
  FAILED = "failed".freeze
  IN_PROGRESS = "in-progress".freeze

  def status
    return IN_PROGRESS if clients_with_in_progress_messages.size > 0
    return FAILED if clients_with_no_successfully_sent_messages.size > 0

    SUCCEEDED
  end

  def clients_with_no_successfully_sent_messages
    failed_emails = outgoing_emails.where(mailgun_status: OutgoingEmail::FAILED_MAILGUN_STATUSES)
    failed_text_messages = outgoing_text_messages.where(twilio_status: OutgoingTextMessage::FAILED_TWILIO_STATUSES)

    clients_with_no_messages = client_selection.clients.where.not(outgoing_emails: outgoing_emails).where.not(outgoing_text_messages: outgoing_text_messages)
    both_failed = client_selection.clients.where(outgoing_text_messages: failed_text_messages, outgoing_emails: failed_emails)
    failed_email_no_text = client_selection.clients.where(outgoing_emails: failed_emails).where.not(outgoing_text_messages: outgoing_text_messages)
    failed_text_no_email = client_selection.clients.where(outgoing_text_messages: failed_text_messages).where.not(outgoing_emails: outgoing_emails)
    clients_with_no_messages.or(both_failed).or(failed_email_no_text).or(failed_text_no_email)
  end

  def clients_with_successfully_sent_messages
    client_selection.clients.where(outgoing_emails: successful_emails).or(client_selection.clients.where(outgoing_text_messages: successful_text_messages))
  end

  def clients_with_in_progress_messages
    in_progress_emails = outgoing_emails.where.not(mailgun_status: OutgoingEmail::SUCCESSFUL_MAILGUN_STATUSES + OutgoingEmail::FAILED_MAILGUN_STATUSES).or(outgoing_emails.where(mailgun_status: nil))
    in_progress_text_messages = outgoing_text_messages.where.not(twilio_status: OutgoingTextMessage::SUCCESSFUL_TWILIO_STATUSES + OutgoingTextMessage::FAILED_TWILIO_STATUSES).or(outgoing_text_messages.where(twilio_status: nil))
    client_selection.clients.where(outgoing_emails: in_progress_emails).or(client_selection.clients.where(outgoing_text_messages: in_progress_text_messages))
  end

  private

  def successful_emails
    outgoing_emails.where(mailgun_status: OutgoingEmail::SUCCESSFUL_MAILGUN_STATUSES)
  end

  def successful_text_messages
    outgoing_text_messages.where(twilio_status: OutgoingTextMessage::SUCCESSFUL_TWILIO_STATUSES)
  end
end
