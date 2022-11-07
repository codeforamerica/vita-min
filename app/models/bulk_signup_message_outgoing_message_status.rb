# == Schema Information
#
# Table name: bulk_signup_message_outgoing_message_statuses
#
#  id                         :bigint           not null, primary key
#  bulk_signup_message_id     :bigint           not null
#  outgoing_message_status_id :bigint           not null
#
# Indexes
#
#  index_bsmoms_on_bulk_signup_messages_id       (bulk_signup_message_id)
#  index_bsmoms_on_outgoing_message_statuses_id  (outgoing_message_status_id)
#
# Foreign Keys
#
#  fk_rails_...  (bulk_signup_message_id => bulk_signup_messages.id)
#  fk_rails_...  (outgoing_message_status_id => outgoing_message_statuses.id)
#
class BulkSignupMessageOutgoingMessageStatus < ApplicationRecord
  belongs_to :bulk_signup_message
  belongs_to :outgoing_message_status
end
