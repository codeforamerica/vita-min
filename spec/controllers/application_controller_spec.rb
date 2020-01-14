require "rails_helper"

RSpec.describe ApplicationController do
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
      request.headers["HTTP_USER_AGENT"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.117 Safari/537.36"

      get :index

      expect(subject.user_agent.name).to eq "Chrome"
    end
  end

  xdescribe "#send_mixpanel_event" do
    it "sends default data to mixpanel" do
    end
  end
end
