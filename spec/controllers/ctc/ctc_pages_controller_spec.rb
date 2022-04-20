require "rails_helper"

describe Ctc::CtcPagesController do
  describe "#home" do
    context "with the ?ctc_beta=1 query parameter" do
      before do
        allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return true
      end

      it "sets the ctc_beta cookie and renders the homepage" do
        get :home, params: { ctc_beta: "1" }

        expect(cookies[:ctc_beta]).to eq('true')
        expect(response).to be_okay
      end
    end

    context "without the ?ctc_beta=1 query parameter" do
      it "renders the homepage without setting the cookie" do
        get :home
        expect(cookies[:ctc_beta]).to be_nil

        expect(response).to be_ok
      end
    end

    context "CDSS landing page content" do
      [
        %w( cactc /en/help ),
        %w( fed   /en/help ),
        %w( eip /en/stimulus-navigator ),
        %w( cagov /en/stimulus-navigator ),
        %w( state /en/stimulus-navigator ),
        %w( credit  /en/stimulus ),
        %w( ca      /en/stimulus ),
        %w( castate /en/stimulus),
      ].each do |source, location, show_needs_help|
        describe "When client visits from source param #{source}" do
          it "redirects to #{location}" do
            session[:source] = source
            get :home
            expect(subject).to redirect_to(location)
          end
        end
      end
    end
  end

  describe "#help" do
    it "renders the home template with the needs_help_banner instance variable set to true" do
      get :help
      expect(session[:source]).to eq "help"
      expect(subject).to render_template(:home)
      expect(assigns(:needs_help_banner)).to eq true
    end
  end

  describe "#stimulus" do
    it "renders the stimulus_home template without the help banner instance variable" do
      get :stimulus
      expect(session[:source]).to eq "stimulus"
      expect(subject).to render_template(:stimulus_home)
      expect(assigns(:needs_help_banner)).to eq nil
    end
  end

  describe "#stimulus_navigator" do
    it "renders the stimulus home template with the needs help banner instance variable set to true" do
      get :stimulus_navigator
      expect(session[:source]).to eq "stimulus-navigator"
      expect(subject).to render_template(:stimulus_home)
      expect(assigns(:needs_help_banner)).to eq true
    end

    context "when session source has already been set" do
      it "does not override it" do
        session[:source] = "original"
        get :stimulus_navigator
        expect(session[:source]).to eq "original"
        expect(subject).to render_template(:stimulus_home)
      end
    end
  end

  describe "#california_benefits" do
    context "source is present" do
      let(:params) { { source: 'claim' } }

      it "saves the source in the session" do
        get :california_benefits, params: params

        expect(session[:source]).to eq "claim"
      end
    end
  end

  describe "#navigators" do
    render_views

    it "renders the content" do
      get :navigators

      expect(response.body).to include "Need help claiming your tax benefits?"
    end
  end
end
