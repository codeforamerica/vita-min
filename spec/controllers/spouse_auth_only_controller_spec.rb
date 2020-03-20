require "rails_helper"

RSpec.describe SpouseAuthOnlyController, type: :controller do
  render_views
  describe "#show" do
    context "with no matching intake" do
      it "displays a message" do
        get :show, params: { token: "br0k3nt0k3n" }

        expect(response).to redirect_to not_found_path
      end
    end

    context "with a matching intake" do
      let(:token) { "t0k3nN0tbr0k3n?" }
      let!(:intake) { create :intake, spouse_auth_token: token }

      it "sets the matching intake as the current intake in the session" do
        get :show, params: { token: token }

        expect(session[:intake_id]).to eq intake.id
      end

      it "sets param in the session to indicate where to direct them after consent" do
        get :show, params: { token: token }

        expect(session[:authenticate_spouse_only]).to eq true
      end

      it "displays a link to authorize path with spouse param" do
        get :show, params: { token: token }

        expect(response.body).to include(user_idme_omniauth_authorize_path(spouse: "true"))
      end
    end
  end
end