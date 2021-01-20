require "rails_helper"

RSpec.describe PublicPagesController do
  render_views

  describe "#home" do
    it "shows an offseason banner" do
      get :home
      expect(response.body).to include("closed for this tax season")
    end

    context "in production" do
      before do
        allow(Rails).to receive(:env).and_return("production".inquiry)
      end

      it "does NOT show a banner warning that this is an example site" do
        get :home

        expect(response.body).not_to include("This site is for example purposes only. If you want help with your taxes, go to")
        expect(response.body).not_to include("https://www.getyourrefund.org")
      end

      it "does show a banner telling users that intakes are closed" do
        get :home
        expect(response.body).to include("services are closed for this tax season.")
      end

      it "includes GA script in html" do
        get :home

        expect(response.body).to include "https://www.googletagmanager.com/gtag/js?id=UA-156157414-1"
      end

      it "does not link to the first question path for digital intake" do
        get :home

        expect(response.body).not_to include "Get started"
        expect(response.body).not_to include question_path(:id => QuestionNavigation.first)
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
    let(:code) { "SourceParameter" }
    let(:params) { { source: code }}
    context "when the source param matches an existing SourceParameter entry associated to an organization" do
      let!(:source_parameter) { create :source_parameter, code: code, vita_partner: create(:vita_partner) }
      it "sets the referring_organization_id to the session" do
        get :source_routing, params: params
        expect(session[:referring_organization_id]).to eq source_parameter.vita_partner.id
      end

      it "redirects to root" do
        expect(
          get :source_routing, params: params
        ).to redirect_to :root
      end
    end

    context "when the source parameter passed does not match an existing SourceParameter entry associated to an organization" do
      it "does not set a referring_organization_id to the session" do
        get :source_routing, params: params
        expect(session[:referring_organization_id]).to eq nil
      end

      it "redirects to root" do
        expect(
          get :source_routing, params: params
        ).to redirect_to :root
      end
    end
  end

  describe "#privacy_policy" do
    it "renders successfully" do
      get :privacy_policy
      expect(response).to be_ok
    end
  end
end
