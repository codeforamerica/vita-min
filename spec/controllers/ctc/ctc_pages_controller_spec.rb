require "rails_helper"

describe Ctc::CtcPagesController do
  describe "#home" do
    context "with the ?ctc_beta=1 query parameter" do
      it "sets the ctc_intake_ok cookie and redirects to intake" do
        get :home, params: {ctc_beta: "1"}

        expect(cookies[:ctc_intake_ok]).to eq('yes')
        expect(response).to redirect_to Ctc::Questions::OverviewController.to_path_helper
      end

      context "when DISABLE_CTC_BETA_PARAM is set" do
        around do |example|
          ENV['DISABLE_CTC_BETA_PARAM'] = '1'
          example.run
          ENV.delete('DISABLE_CTC_BETA_PARAM')
        end

        it "renders the home page without any cookies or redirects" do
          get :home
          expect(cookies[:ctc_intake_ok]).to be_nil
          expect(response).to be_ok
        end
      end
    end

    context "without the ?ctc_beta=1 query parameter" do
      it "renders the homepage" do
        get :home
        expect(response).to be_ok
      end
    end

    context "CDSS landing page content" do
      [
        %w( cactc ctc/ctc_pages/home true),
        %w( fed   ctc/ctc_pages/home true),
        %w( child ctc/ctc_pages/home true),
        %w( eip ctc/ctc_pages/stimulus_home true),
        %w( cagov ctc/ctc_pages/stimulus_home true),
        %w( state ctc/ctc_pages/stimulus_home true),
        %w( credit  ctc/ctc_pages/stimulus_home false),
        %w( ca      ctc/ctc_pages/stimulus_home false),
        %w( castate ctc/ctc_pages/stimulus_home false),
      ].each do |source, template, show_needs_help|
        describe "When client visits from source param #{source}" do
          it "renders #{template} and #{show_needs_help ? 'does' : 'does not'} show blue banner" do
            session[:source] = source
            get :home
            expect(subject).to render_template(template)
            show_needs_help_bool = show_needs_help == 'true' ? true : false
            expect(!!assigns[:needs_help_banner]).to eq(show_needs_help_bool)
          end
        end
      end
    end
  end

  describe "#navigators" do
    render_views

    it "renders the content" do
      get :navigators

      expect(response.body).to include "1. Getting Started"
    end
  end
end
