require "rails_helper"

RSpec.describe PublicPagesController do
  render_views

  describe "#home" do
    let(:demo_banner_text) { I18n.t('views.shared.environment_warning.banner') }

    context "in production" do
      before do
        allow(Rails).to receive(:env).and_return("production".inquiry)
      end

      it "does NOT show a banner warning that this is an example site" do
        get :home

        expect(response.body).not_to include(demo_banner_text)
      end

      it "includes GA script in html" do
        get :home

        expect(response.body).to include "https://www.googletagmanager.com/gtag/js?id=UA-156157414-1"
      end

      context "when source is full-service" do
        it "redirects to the Backtaxes question" do
          get :home, params: { source: "full-service" }

          expect(response).to redirect_to Questions::BacktaxesController.to_path_helper
        end
      end

      context "when source is not full-service" do
        it "does not redirect" do
          get :home, params: { source: "stimulus" }

          expect(response).to render_template :home
        end
      end

      context "when the app is open for intake" do
        it "links to the first question path for digital intake" do
          get :home

          expect(response.body).to include I18n.t('general.get_started')
          expect(response.body).to include question_path(:id => GyrQuestionNavigation.first)
        end
      end

      context "when the app is not open for intake" do
        before do
          allow(subject).to receive(:open_for_intake?).and_return(false)
        end

        it "links to the first question path for digital intake" do
          get :home

          expect(response.body).not_to include I18n.t('general.get_started')
          expect(response.body).not_to include question_path(:id => GyrQuestionNavigation.first)
        end
      end
    end

    context "in demo env" do
      before do
        allow(Rails).to receive(:env).and_return("demo".inquiry)
      end

      it "shows a banner warning that this is an example site" do
        get :home

        expect(response.body).to include(demo_banner_text)
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

  describe "#healthcheck" do
    it "renders the same content as the home page" do
      get :healthcheck
      expect(response).to be_ok
      expect(response.body).to include I18n.t("views.public_pages.home.header")
    end
  end

  describe "#source_routing" do
    context "when it can find a matching source parameter" do
      let(:source_parameter) { create :source_parameter, vita_partner: (create :organization, name: "Oregano Organization") }

      it "renders the home template with a welcome message" do
        get :source_routing, params: { source: source_parameter.code }
        expect(flash[:notice]).to eq "Thanks for visiting via Oregano Organization!"
        expect(response).to redirect_to :root
      end

      it "sets the used_unique_link cookie" do
        get :source_routing, params: { source: source_parameter.code }
        expect(cookies[:used_unique_link]).to eq("yes")
      end
    end

    context "when there is no matching source parameter" do
      it "redirects to home" do
        get :source_routing, params: { source: "no-match" }
        expect(response).to redirect_to :root
      end

      it "does not set the used_unique_link cookie" do
        get :source_routing, params: { source: "no-match" }
        expect(cookies[:used_unique_link]).to be_nil
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
end
