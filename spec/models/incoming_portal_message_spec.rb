# == Schema Information
#
# Table name: incoming_portal_messages
#
#  id         :bigint           not null, primary key
#  body       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  client_id  :bigint
#
# Indexes
#
#  index_incoming_portal_messages_on_client_id  (client_id)
#
require 'rails_helper'

RSpec.describe IncomingPortalMessage, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
