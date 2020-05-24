require "rails_helper"

RSpec.describe Zendesk::DocumentsController do
  describe "#show" do
    let(:intake) { create :intake, intake_ticket_id: 123 }
    let!(:document) { create :document, :with_upload, intake: intake }
    let(:user) { create :user, provider: "zendesk" }

    context "when logged out" do
      it "redirects to the sign in page" do
        get :show, params: { id: document.id }
        expect(response).to redirect_to(zendesk_sign_in_path)
      end
    end

    context "as an authenticated zendesk user" do
      before do
        allow(subject).to receive(:current_user).and_return(user)
      end

      context "without access to the particular zendesk ticket" do
        before do
          allow(subject).to receive(:current_ticket).and_return nil
        end

        it "renders not found" do
          get :show, params: { id: document.id }

          expect(response.status).to eq 404
          expect(response).to render_template "public_pages/page_not_found"
        end
      end

      context "with access to the ticket" do
        let(:ticket) { instance_double(ZendeskAPI::Ticket) }

        before do
          allow(subject).to receive(:current_ticket).and_return(ticket)
        end

        it "renders the document" do
          get :show, params: { id: document.id }

          expect(response).to be_ok
          expect(response.headers["Content-Type"]).to eq("image/jpeg")
        end
      end
    end
  end
end
