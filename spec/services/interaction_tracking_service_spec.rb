require 'rails_helper'

describe InteractionTrackingService do
  let(:client) { create(:client) }
  let(:fake_time) { Time.utc(2021, 2, 6, 0, 0, 0) }

  describe ".update_last_outgoing_interaction_at" do
    it "updates Client.last_outgoing_interaction_at" do
      Timecop.freeze(fake_time) do
        expect { described_class.update_last_outgoing_interaction_at(client) }.to change { client.last_outgoing_interaction_at }.from(nil).to(fake_time)
      end
    end
  end
end
