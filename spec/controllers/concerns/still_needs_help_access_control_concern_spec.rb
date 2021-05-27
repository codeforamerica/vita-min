require "rails_helper"

RSpec.describe StillNeedsHelpAccessControlConcern, type: :controller do
  controller(ApplicationController) do
    include StillNeedsHelpAccessControlConcern
    before_action :require_still_needs_help_client_login

    def index
      head :ok
    end
  end

  describe "#require_still_needs_help_client_login" do
    context "when a client is not authenticated" do
      it "redirects to a login page" do
        get :index

        expect(response).to redirect_to new_portal_client_login_path
      end
    end

    context "when a client is authenticated" do
      let(:client) { create(:intake).client }

      before { sign_in client }

      context "with a client who may see the Still Needs Help flow" do
        before do
          allow(StillNeedsHelpService).to receive(:may_show_still_needs_help_flow?).with(client).and_return(true)
        end

        it "does not redirect" do
          get :index

          expect(response).to be_ok
        end
      end

      context "with a client who may not see the Still Needs Help flow" do
        before do
          allow(StillNeedsHelpService).to receive(:may_show_still_needs_help_flow?).with(client).and_return(false)
        end

        it "redirects to portal home" do
          get :index

          expect(response).to redirect_to(portal_root_path)
        end
      end
    end
  end
end
