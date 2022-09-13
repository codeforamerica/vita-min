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
  has_one :user_notification, as: :notifiable
  belongs_to :tax_return_selection
  has_many :bulk_client_message_outgoing_emails
  has_many :bulk_client_message_outgoing_text_messages
  has_many :outgoing_emails, through: :bulk_client_message_outgoing_emails
  has_many :outgoing_text_messages, through: :bulk_client_message_outgoing_text_messages

  SUCCEEDED = "succeeded".freeze
  FAILED = "failed".freeze
  IN_PROGRESS = "in-progress".freeze

  def status
    return cached_data[:status] if cached_data[:status]

    _status = if cacheable_count(:clients_with_in_progress_messages) > 0
      IN_PROGRESS
    elsif cacheable_count(:clients_with_no_successfully_sent_messages) > 0
      FAILED
    else
      SUCCEEDED
    end

    if _status != IN_PROGRESS
      cached_data[:status] = _status
      save
    end

    _status
  end

  def cacheable_count(method)
    if cached_data[:status].present?
      if cached_data[method].blank?
        cached_data[method] = send(method).size
        save
      end
      cached_data[method]
    else
      memoized_counts[method] ||= send(method).size
    end
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
    @_memoized_counts = {}
    super
  end

  private

  def memoized_counts
    @_memoized_counts ||= {}
  end
end
