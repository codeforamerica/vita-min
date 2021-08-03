require "rails_helper"

RSpec.describe AuthenticatedCtcClientConcern, type: :controller do
  describe "before actions" do
    controller(ApplicationController) do
      include AuthenticatedCtcClientConcern

      def index
        head :ok
      end
    end

    context "when a client is not authenticated" do
      it "redirects to a login page" do
        get :index

        expect(response).to redirect_to new_ctc_portal_client_login_path
      end

      it "adds the current path to the session" do
        get :index, params: { with_querystring: "cool" }

        expect(session[:after_client_login_path]).to eq("/anonymous?with_querystring=cool")
      end

      context "with a POST request" do
        it "redirects but does not store the current path in the session" do
          post :index

          expect(response).to redirect_to new_ctc_portal_client_login_path
          expect(session).not_to include :after_client_login_path
        end
      end
    end

    context "when a client is authenticated" do
      let(:client) { create(:client) }
      before { sign_in client }

      it "does not redirect and doesn't store the current path in the session" do
        get :index

        expect(response).to be_ok
        expect(session).not_to include :after_client_login_path
      end

      it "updates Client last_seen_at" do
        fake_time = Time.utc(2021, 2, 6, 0, 0, 0)
        expect do
          Timecop.freeze(fake_time) do
            get :index
          end
        end.to change { client.reload.last_seen_at }.from(nil).to(fake_time)
      end
    end
  end
end
