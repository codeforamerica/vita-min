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

  describe "#source" do
    context "with an existing source in the session" do
      before { session[:source] = "shrimps" }

      it "returns the session value" do
        get :index

        expect(subject.source).to eq "shrimps"
      end
    end

    context "with a 'source' param" do
      let(:params) do
        { source: "shromps"}
      end

      it "stores the param in the session" do
        get :index, params: params

        expect(session[:source]).to eq "shromps"
      end
    end

    context "with an 's' param" do
      let(:params) do
        { s: "shremps"}
      end

      it "stores the param in the session" do
        get :index, params: params

        expect(session[:source]).to eq "shremps"
      end
    end

    context "with an google.com referer header" do
      before { request.headers["HTTP_REFERER"] = "http://google.com/search" }

      it "stores the param in the session" do
        get :index

        expect(session[:source]).to eq "organic_google"
      end
    end
  end

  describe "#referrer" do
    context "with an existing referrer in the session" do
      before do
        session[:referrer] = "searchengine.shrimp"
        request.headers["HTTP_REFERER"] = "/previous_page"
      end

      it "does not override it" do
        get :index

        expect(subject.referrer).to eq "searchengine.shrimp"
      end
    end

    context "with no referrer in the session" do
      context "with an HTTP_REFERER header" do
        before { request.headers["HTTP_REFERER"] = "coolwebsite.horse" }

        it "sets the referrer from the headers" do
          get :index

          expect(session[:referrer]).to eq "coolwebsite.horse"
        end
      end

      context "without an HTTP_REFERER header" do
        it "sets the referrer to 'None'" do
          get :index

          expect(session[:referrer]).to eq "None"
        end
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

    before do
      allow(MixpanelService).to receive(:instance).and_return(mixpanel_spy)
      cookies[:visitor_id] = "123"
      session[:source] = "vdss"
      request.headers["HTTP_USER_AGENT"] = user_agent_string
      request.headers["HTTP_REFERER"] = "http://coolwebsite.horse/tax-help/vita"
    end

    it "sends default data using mixpanel service" do
      get :index

      subject.send_mixpanel_event(event_name: "beep", data: { sound: "boop" })
      expected_mixpanel_data = {
        sound: "boop",
        source: "vdss",
        referrer: "http://coolwebsite.horse/tax-help/vita",
        referrer_domain: "coolwebsite.horse",
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
      expect(mixpanel_spy).to have_received(:run).with(
        unique_id: "123",
        event_name: "beep",
        data: expected_mixpanel_data
      )
    end

    context "with a request from a bot" do
      let(:user_agent_string) { "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)" }

      it "sends nothing to mixpanel" do
        get :index

        subject.send_mixpanel_event(event_name: "beep")
        expect(mixpanel_spy).not_to have_received(:run)
      end
    end
  end
end
