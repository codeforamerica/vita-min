require "rails_helper"

RSpec.describe AuthenticatedStateFileIntakeConcern, type: :controller do
  describe "before actions" do
    controller(ApplicationController) do
      include AuthenticatedStateFileIntakeConcern

      def index
        head :ok
      end
    end

    context "when a state file intake is not authenticated" do
      it "redirects to a login page" do
        get :index

        expect(response).to redirect_to root_path
      end

      it "adds the current path to the session" do
        get :index, params: { with_querystring: "cool" }

        expect(session[:after_state_file_intake_login_path]).to eq("/anonymous?with_querystring=cool")
      end

      context "with a POST request" do
        it "redirects but does not store the current path in the session" do
          post :index

          expect(response).to redirect_to root_path
          expect(session).not_to include :after_state_file_intake_login_path
        end
      end
    end

    context "when a state file intake is authenticated" do
      before { sign_in create(:state_file_az_intake) }

      it "does not redirect and doesn't store the current path in the session" do
        get :index

        expect(response).to be_ok
        expect(session).not_to include :after_state_file_intake_login_path
      end
    end
  end
end
