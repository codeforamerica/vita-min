require 'rails_helper'

describe OutboundCall do
  it_behaves_like "an outgoing interaction" do
    let(:subject) { build(:outbound_call) }
  end
end