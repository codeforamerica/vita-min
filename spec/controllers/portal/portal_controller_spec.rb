require "rails_helper"

RSpec.describe Portal::PortalController, type: :controller do
  describe "#home" do
    context "when unauthenticated" do
      it "redirects to home page" do
        get :home
        # TODO: once the rest of the login flow is implemented we want to change this to redirect to the client sign in path
        expect(response).to redirect_to(root_path)
      end
    end

    context "as an authenticated client" do
      before { sign_in create :client }

      it "is ok" do
        get :home

        expect(response).to be_ok
      end
    end
  end
end
