# == Schema Information
#
# Table name: bulk_client_message_outgoing_text_messages
#
#  id                       :bigint           not null, primary key
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  bulk_client_message_id   :bigint           not null
#  outgoing_text_message_id :bigint           not null
#
# Indexes
#
#  index_bcmotm_on_bulk_client_message_id    (bulk_client_message_id)
#  index_bcmotm_on_outgoing_text_message_id  (outgoing_text_message_id)
#
# Foreign Keys
#
#  fk_rails_...  (bulk_client_message_id => bulk_client_messages.id)
#  fk_rails_...  (outgoing_text_message_id => outgoing_text_messages.id)
#
class BulkClientMessageOutgoingTextMessage < ApplicationRecord
  belongs_to :bulk_client_message
  belongs_to :outgoing_text_message
end
