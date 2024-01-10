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
        get :index, params: { us_state: "ny" }

        expect(response).to redirect_to StateFile::StateFilePagesController.to_path_helper(action: :login_options, us_state: "ny")
      end

      it "adds the current path to the session" do
        get :index, params: { us_state: "ny", with_querystring: "cool" }

        stored_path = URI(session[:after_state_file_intake_login_path])
        stored_params = Rack::Utils.parse_query stored_path.query
        expect(stored_path.path).to eq("/anonymous")
        expect(stored_params["with_querystring"]).to eq "cool"
        expect(stored_params["us_state"]).to eq "ny"
      end

      context "with a POST request" do
        it "redirects but does not store the current path in the session" do
          post :index, params: { us_state: "az" }

          expect(response).to redirect_to StateFile::StateFilePagesController.to_path_helper(action: :login_options, us_state: "az")
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

      context "when the session is timed out" do
        before do
          allow_any_instance_of(StateFileAzIntake).to receive(:timedout?).and_return(true)
        end
        it "sessions time out" do
          get :index, params: { us_state: "az" }
          expect(response).to redirect_to root_path
        end
      end
    end
  end
end
