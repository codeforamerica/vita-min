require "rails_helper"

describe MixpanelJob do
  describe "#perform" do
    before do
      allow(MixpanelService.instance).to receive(:run)
    end

    it "calls Mixpanel" do
      subject.perform(distinct_id: "id", event_name: "evt", data: {"data": "yes"})

      expect(MixpanelService.instance).to have_received(:run).with(distinct_id: "id", event_name: "evt", data: {"data": "yes"})
    end
  end
end
