# == Schema Information
#
# Table name: bulk_client_messages
#
#  id                      :bigint           not null, primary key
#  cached_data             :jsonb
#  send_only               :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  tax_return_selection_id :bigint
#
# Indexes
#
#  index_bcm_on_tax_return_selection_id  (tax_return_selection_id)
#
# Foreign Keys
#
#  fk_rails_...  (tax_return_selection_id => tax_return_selections.id)
#
class BulkClientMessage < ApplicationRecord
  has_one :user_notification, as: :notifiable, dependent: :destroy
  belongs_to :tax_return_selection
  has_many :bulk_client_message_outgoing_emails
  has_many :bulk_client_message_outgoing_text_messages
  has_many :outgoing_emails, through: :bulk_client_message_outgoing_emails
  has_many :outgoing_text_messages, through: :bulk_client_message_outgoing_text_messages

  SUCCEEDED = "succeeded".freeze
  FAILED = "failed".freeze
  IN_PROGRESS = "in-progress".freeze

  def flush_memoized_data
    if status != IN_PROGRESS
      update_column(:cached_data, cached_data.merge(memoized_data))
    end
  end

  def status
    if cacheable_count(:clients_with_in_progress_messages) > 0
      IN_PROGRESS
    elsif cacheable_count(:clients_with_no_successfully_sent_messages) > 0
      FAILED
    else
      SUCCEEDED
    end
  end

  def cacheable_count(method_sym)
    memoized_data["#{method_sym}_count"] ||= send(method_sym).size
  end

  def clients
    tax_return_selection.clients
  end

  def clients_with_no_successfully_sent_messages
    clients_with_no_messages = tax_return_selection.clients.where.not(outgoing_emails: outgoing_emails).where.not(outgoing_text_messages: outgoing_text_messages)
    both_failed = tax_return_selection.clients.where(outgoing_text_messages: outgoing_text_messages.failed, outgoing_emails: outgoing_emails.failed)
    failed_email_no_text = tax_return_selection.clients.where(outgoing_emails: outgoing_emails.failed).where.not(outgoing_text_messages: outgoing_text_messages)
    failed_text_no_email = tax_return_selection.clients.where(outgoing_text_messages: outgoing_text_messages.failed).where.not(outgoing_emails: outgoing_emails)

    clients_with_no_messages.or(both_failed).or(failed_email_no_text).or(failed_text_no_email)
  end

  def clients_with_successfully_sent_messages
    tax_return_selection.clients.where(outgoing_emails: outgoing_emails.succeeded).or(tax_return_selection.clients.where(outgoing_text_messages: outgoing_text_messages.succeeded))
  end

  def clients_with_in_progress_messages
    tax_return_selection.clients.where(outgoing_emails: outgoing_emails.in_progress).or(tax_return_selection.clients.where(outgoing_text_messages: outgoing_text_messages.in_progress))
  end

  def reload
    super
    @_memoized_data = cached_data.dup
  end

  private

  def memoized_data
    @_memoized_data ||= cached_data.dup
  end
end
