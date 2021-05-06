# == Schema Information
#
# Table name: bulk_client_messages
#
#  id                      :bigint           not null, primary key
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  client_selection_id     :bigint
#  tax_return_selection_id :bigint
#
# Indexes
#
#  index_bcm_on_tax_return_selection_id               (tax_return_selection_id)
#  index_bulk_client_messages_on_client_selection_id  (client_selection_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_selection_id => client_selections.id)
#  fk_rails_...  (tax_return_selection_id => tax_return_selections.id)
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
    clients_with_no_messages = client_selection.clients.where.not(outgoing_emails: outgoing_emails).where.not(outgoing_text_messages: outgoing_text_messages)
    both_failed = client_selection.clients.where(outgoing_text_messages: outgoing_text_messages.failed, outgoing_emails: outgoing_emails.failed)
    failed_email_no_text = client_selection.clients.where(outgoing_emails: outgoing_emails.failed).where.not(outgoing_text_messages: outgoing_text_messages)
    failed_text_no_email = client_selection.clients.where(outgoing_text_messages: outgoing_text_messages.failed).where.not(outgoing_emails: outgoing_emails)

    clients_with_no_messages.or(both_failed).or(failed_email_no_text).or(failed_text_no_email)
  end

  def clients_with_successfully_sent_messages
    client_selection.clients.where(outgoing_emails: outgoing_emails.succeeded).or(client_selection.clients.where(outgoing_text_messages: outgoing_text_messages.succeeded))
  end

  def clients_with_in_progress_messages
    client_selection.clients.where(outgoing_emails: outgoing_emails.in_progress).or(client_selection.clients.where(outgoing_text_messages: outgoing_text_messages.in_progress))
  end
end
