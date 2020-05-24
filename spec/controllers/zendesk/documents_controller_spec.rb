require "rails_helper"

RSpec.describe Zendesk::DocumentsController do
  describe "#show" do
    let(:intake) { create :intake, intake_ticket_id: 123 }
    let!(:document) { create :document, :with_upload, intake: intake }
    let(:user) { create :user, provider: "zendesk" }

    it_behaves_like :a_protected_zendesk_ticket_page do
      let(:valid_params) do
        { id: document.id }
      end
    end

    context "as an authenticated zendesk user with ticket access" do
      let(:ticket) { instance_double(ZendeskAPI::Ticket) }

      before do
        allow(subject).to receive(:current_user).and_return(user)
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
