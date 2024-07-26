require "rails_helper"

RSpec.describe StateFile::StateFileIntakeConcern, type: :controller do
  controller(ApplicationController) do
    include StateFile::StateFileIntakeConcern

    def index
      head :ok
    end
  end

  describe "helper methods" do
    before { sign_in create(:state_file_az_intake) }

    describe "#current_state_code" do
      context "when there is a logged in intake" do
        it "returns the state code from the logged in intake" do
          expect(subject.current_state_code).to eq "az"
        end
      end
    end

    describe "#current_state_name" do
      it "returns the state name from the information service based on current_state_code" do
        expect(subject.current_state_name).to eq "Arizona"
      end
    end
  end

  describe "before actions" do
    context "when a state file intake is not authenticated" do
      it "redirects to a login page" do
        get :index

        expect(response).to redirect_to StateFile::StateFilePagesController.to_path_helper(action: :login_options)
      end

      it "adds the current path to the session" do
        get :index, params: { with_querystring: "cool" }

        stored_path = URI(session[:after_state_file_intake_login_path])
        stored_params = Rack::Utils.parse_query stored_path.query
        expect(stored_path.path).to eq("/anonymous")
        expect(stored_params["with_querystring"]).to eq "cool"
      end

      context "with a POST request" do
        it "redirects but does not store the current path in the session" do
          post :index

          expect(response).to redirect_to StateFile::StateFilePagesController.to_path_helper(action: :login_options)
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
          get :index
          expect(response).to redirect_to root_path
        end
      end
    end
  end
end
