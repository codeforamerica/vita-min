require "rails_helper"

RSpec.describe Zendesk::DropOffsController do
  describe "#show" do
    let!(:drop_off) { create :intake_site_drop_off }
    let(:user) { create :user, provider: "zendesk" }

    it_behaves_like :a_protected_zendesk_ticket_page do
      let(:valid_params) do
        { id: drop_off.id }
      end
    end

    context "as an authenticated zendesk user with ticket access" do
      let(:ticket) { instance_double(ZendeskAPI::Ticket) }

      before do
        allow(subject).to receive(:current_user).and_return(user)
        allow(subject).to receive(:current_ticket).and_return(ticket)
      end

      it "renders the document" do
        get :show, params: { id: drop_off.id }

        expect(response).to be_ok
        expect(response.headers["Content-Type"]).to eq("application/pdf")
      end
    end

    context "as an authenticated user without ticket access" do
      before do
        allow(subject).to receive(:current_user).and_return(user)
      end

      it "returns 404 with a not found page" do
        get :show, params: { id: drop_off.id }

        expect(response.status).to eq 404
        expect(response).to render_template "public_pages/page_not_found"
      end
    end
  end
end
