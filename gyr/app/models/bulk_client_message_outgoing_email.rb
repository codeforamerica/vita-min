# == Schema Information
#
# Table name: bulk_client_message_outgoing_emails
#
#  id                     :bigint           not null, primary key
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  bulk_client_message_id :bigint           not null
#  outgoing_email_id      :bigint           not null
#
# Indexes
#
#  index_bcmoe_on_bulk_client_message_id  (bulk_client_message_id)
#  index_bcmoe_on_outgoing_email_id       (outgoing_email_id)
#
# Foreign Keys
#
#  fk_rails_...  (bulk_client_message_id => bulk_client_messages.id)
#  fk_rails_...  (outgoing_email_id => outgoing_emails.id)
#
class BulkClientMessageOutgoingEmail < ApplicationRecord
  belongs_to :bulk_client_message
  belongs_to :outgoing_email
end
