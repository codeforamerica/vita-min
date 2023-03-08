require "rails_helper"

describe Ctc::Questions::OverviewController do
  context '#update' do
    let(:params) { {} }

    before do
      cookies[:visitor_id] = "a" * 52
      allow(MixpanelService).to receive(:send_event)
    end

    it "sends an event to mixpanel" do
      post :update, params: params

      expect(MixpanelService).to have_received(:send_event).with(hash_including(
        event_name: "ctc_started_flow",
        distinct_id: "a" * 52,
      ))
    end
  end
end
