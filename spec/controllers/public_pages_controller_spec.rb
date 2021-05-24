require "rails_helper"

RSpec.describe PublicPagesController do
  render_views

  describe "#home" do
    context "in production" do
      before do
        allow(Rails).to receive(:env).and_return("production".inquiry)
      end

      it "does NOT show a banner warning that this is an example site" do
        get :home

        expect(response.body).not_to include("This site is for example purposes only. If you want help with your taxes, go to")
      end

      it "includes GA script in html" do
        get :home

        expect(response.body).to include "https://www.googletagmanager.com/gtag/js?id=UA-156157414-1"
      end

      it "links to the first question path for digital intake" do
        get :home

        expect(response.body).to include "Get started"
        expect(response.body).to include question_path(:id => QuestionNavigation.first)
      end
    end

    context "in demo env" do
      before do
        allow(Rails).to receive(:env).and_return("demo".inquiry)
      end

      it "shows a banner warning that this is an example site" do
        get :home

        expect(response.body).to include("This site is for example purposes only. If you want help with your taxes, go to")
        expect(response.body).to include("https://www.getyourrefund.org")
      end

      it "does not include google analytics" do
        get :home
        expect(response.body).not_to include "https://www.googletagmanager.com/gtag/js?id=UA-156157414-1"
      end
    end

    context "in development env" do
      before do
        allow(Rails).to receive(:env).and_return("development".inquiry)
      end

      it "does not include google analytics" do
        get :home
        expect(response.body).not_to include "https://www.googletagmanager.com/gtag/js?id=UA-156157414-1"
      end
    end

    context "in test env" do
      before do
        allow(Rails).to receive(:env).and_return("test".inquiry)
      end

      it "does not include google analytics" do
        get :home
        expect(response.body).not_to include "https://www.googletagmanager.com/gtag/js?id=UA-156157414-1"
      end
    end
  end

  describe "#source_routing" do
    context "when it can find a matching source parameter" do
      let(:source_parameter) { create :source_parameter, vita_partner: (create :vita_partner, name: "Oregano Organization") }

      it "renders the home template with a welcome message" do
        get :source_routing, params: { source: source_parameter.code }
        expect(flash[:notice]).to eq "Thanks for visiting via Oregano Organization!"
        expect(response).to redirect_to :root
      end

      it "sets the cookie intake_open" do
        get :source_routing, params: { source: source_parameter.code }
        expect(cookies[:intake_open]).to be_present
      end
    end

    context "when there is no matching source parameter" do
      it "redirects to home" do
        get :source_routing, params: { source: "no-match" }
        expect(response).to redirect_to :root
      end

      it "does not set the session intake_open" do
        get :source_routing, params: { source: "no-match" }
        expect(cookies[:intake_open]).to be_nil
      end
    end
  end

  describe "#privacy_policy" do
    it "renders successfully" do
      get :privacy_policy
      expect(response).to be_ok
    end
  end

  describe "#diy" do
    it "renders successfully" do
      get :diy
      expect(response).to be_ok
    end
  end

  describe "#faq" do
    it "renders successfully" do
      get :faq
      expect(response).to be_ok
    end
  end

  describe "#ctc_faq" do
    it "renders successfully" do
      get :ctc_faq
      expect(response).to be_ok
    end
  end
end
