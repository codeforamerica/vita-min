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
#  index_incoming_portal_messages_on_client_id   (client_id)
#  index_incoming_portal_messages_on_created_at  (created_at)
#
require 'rails_helper'

RSpec.describe IncomingPortalMessage, type: :model do
  it_behaves_like "an incoming interaction" do
    let(:subject) { build(:incoming_portal_message) }
  end
end
