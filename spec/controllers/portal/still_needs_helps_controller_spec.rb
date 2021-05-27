require "rails_helper"

describe Portal::StillNeedsHelpsController do
  let(:client) { create(:intake).client }

  describe "#index" do
    context "with an authenticated client" do
      before do
        sign_in client, scope: :client
      end

      context "when the client may see the still need help flow" do
        before do
          allow(StillNeedsHelpService).to receive(:may_show_still_needs_help_flow?).with(client).and_return(true)
        end

        it "is ok" do
          get :index

          expect(response).to be_ok
        end
      end

      context "when the client may not see the still need help flow" do
        before do
          allow(StillNeedsHelpService).to receive(:may_show_still_needs_help_flow?).with(client).and_return(false)
        end

        it "redirects to portal home" do
          get :index

          expect(response).to redirect_to(portal_root_path)
        end

      end
    end

    context "without an authenticated client" do
      it "redirects to portal login" do
        get :index

        expect(response).to redirect_to(new_portal_client_login_path)
      end
    end
  end
end
