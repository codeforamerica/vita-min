require "rails_helper"

RSpec.describe ClientAccessControlConcern, type: :controller do
  controller(ApplicationController) do
    include ClientAccessControlConcern
    before_action :require_client_login

    def index
      head :ok
    end
  end

  describe "#require_client_login" do
    context "when a client is not authenticated" do
      it "redirects to a login page" do
        get :index

        expect(response).to redirect_to new_portal_client_login_path
      end

      it "adds the current path to the session" do
        get :index, params: { with_querystring: "cool" }

        expect(session[:after_client_login_path]).to eq("/anonymous?with_querystring=cool")
      end

      context "with a POST request" do
        it "redirects but does not store the current path in the session" do
          post :index

          expect(response).to redirect_to new_portal_client_login_path
          expect(session).not_to include :after_client_login_path
        end
      end
    end

    context "when a client is authenticated" do
      before { sign_in create(:client) }

      it "does not redirect and doesn't store the current path in the session" do
        get :index

        expect(response).to be_ok
        expect(session).not_to include :after_client_login_path
      end
    end

    context "with a client who has triggered the Still Need Help page" do
      before { sign_in create(:client, triggered_still_needs_help_at: Time.now) }

      it "redirects to Still Need Help page" do
        get :index

        expect(response).to redirect_to(portal_still_needs_helps_path)
        expect(session).not_to include :after_client_login_path
      end
    end
  end
end
