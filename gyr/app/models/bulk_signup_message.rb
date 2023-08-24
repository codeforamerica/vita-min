# == Schema Information
#
# Table name: bulk_signup_messages
#
#  id                  :bigint           not null, primary key
#  message             :text             not null
#  message_type        :integer          not null
#  subject             :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  signup_selection_id :bigint           not null
#  user_id             :bigint           not null
#
# Indexes
#
#  index_bulk_signup_messages_on_signup_selection_id  (signup_selection_id)
#  index_bulk_signup_messages_on_user_id              (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (signup_selection_id => signup_selections.id)
#  fk_rails_...  (user_id => users.id)
#
class BulkSignupMessage < ApplicationRecord
  enum message_type: { sms: 1, email: 2 }, _prefix: :message_type

  belongs_to :user
  belongs_to :signup_selection
  has_many :bulk_signup_message_outgoing_message_statuses
  has_many :outgoing_message_statuses, through: :bulk_signup_message_outgoing_message_statuses

  validates :message, presence: true
  validates :subject, presence: true, if: -> { message_type == 'email' }

  def succeeded_messages_count
    outgoing_message_statuses.group(:delivery_status).count.select { |status, _count| successful_statuses.include?(status) }.values.sum
  end

  def failed_messages_count
    outgoing_message_statuses.group(:delivery_status).count.select { |status, _count| failed_statuses.include?(status) }.values.sum
  end

  def pending_messages_count
    signup_count - succeeded_messages_count - failed_messages_count
  end

  def sending_complete?
    pending_messages_count.zero?
  end

  def signup_count
    signup_selection.id_array.length
  end

  private

  def successful_statuses
    if message_type_sms?
      TwilioService::SUCCESSFUL_STATUSES
    else
      OutgoingEmail::SUCCESSFUL_MAILGUN_STATUSES
    end
  end

  def failed_statuses
    if message_type_sms?
      TwilioService::FAILED_STATUSES
    else
      OutgoingEmail::FAILED_MAILGUN_STATUSES
    end
  end
end
