require "rails_helper"

RSpec.describe ApplicationController do
  let(:user_agent_string) { "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.117 Safari/537.360" }

  controller do
    def index
      head :ok
    end
  end

  describe "#include_google_analytics?" do
    it "returns false" do
      expect(subject.include_google_analytics?).to eq false
    end
  end

  describe "#set_visitor_id" do
    context "existing visitor id" do
      before do
        cookies[:visitor_id] = "123"
      end

      it "retains the existing visitor id" do
        get :index
        expect(cookies[:visitor_id]).to eq "123"
      end
    end

    context "no visitor id" do
      it "generates and sets a visitor id cookie" do
        get :index
        expect(cookies[:visitor_id]).to be_a String
        expect(cookies[:visitor_id]).to be_present
      end
    end
  end

  describe "#user_agent" do
    it "parses the user agent" do
      request.headers["HTTP_USER_AGENT"] = user_agent_string

      get :index

      expect(subject.user_agent.name).to eq "Chrome"
    end
  end

  describe "#send_mixpanel_event" do
    let(:mixpanel_spy) { spy(MixpanelService) }
    let(:expected_data) do
      {
        sound: "boop",
        full_user_agent: user_agent_string,
        browser_name: "Chrome",
        browser_full_version: "79.0.3945.117",
        browser_major_version: "79",
        os_name: "Mac",
        os_full_version: "10.15.2",
        os_major_version: "10",
        is_bot: false,
        bot_name: nil,
        device_brand: nil,
        device_name: nil,
        device_type: "desktop",
        device_browser_version: "Mac desktop Chrome 79",
        locale: "en",
        path: "/anonymous",
        full_path: "/anonymous",
        controller_name: "Anonymous",
        controller_action: "AnonymousController#index",
        controller_action_name: "index",
      }
    end

    before do
      allow(MixpanelService).to receive(:instance).and_return(mixpanel_spy)
      cookies[:visitor_id] = "123"
      request.headers["HTTP_USER_AGENT"] = user_agent_string
    end

    it "sends default data using mixpanel service" do
      get :index

      subject.send_mixpanel_event(event_name: "beep", data: { sound: "boop" })

      expect(mixpanel_spy).to have_received(:run).with(
        unique_id: "123",
        event_name: "beep",
        data: expected_data
      )
    end
  end
end
