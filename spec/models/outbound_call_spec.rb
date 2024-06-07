# == Schema Information
#
# Table name: outbound_calls
#
#  id                   :bigint           not null, primary key
#  from_phone_number    :string           not null
#  note                 :text
#  queue_time_ms        :integer
#  to_phone_number      :string           not null
#  twilio_call_duration :integer
#  twilio_sid           :string
#  twilio_status        :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  client_id            :bigint
#  user_id              :bigint
#
# Indexes
#
#  index_outbound_calls_on_client_id   (client_id)
#  index_outbound_calls_on_created_at  (created_at)
#  index_outbound_calls_on_user_id     (user_id)
#
require 'rails_helper'

describe OutboundCall do
  it_behaves_like "a user-initiated outgoing interaction" do
    let(:subject) { build(:outbound_call) }
  end

  it_behaves_like "an outgoing interaction" do
    let(:subject) { build :outgoing_text_message }
  end
end
