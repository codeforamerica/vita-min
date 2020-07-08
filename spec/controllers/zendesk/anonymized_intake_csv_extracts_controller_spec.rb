require "rails_helper"

RSpec.describe Zendesk::AnonymizedIntakeCsvExtractsController do
  let(:user) { create :user, provider: "zendesk", role: role }
  let(:role) { "admin" }
  before { allow(subject).to receive(:current_user).and_return(user) }

  shared_examples "requires Zendesk admin" do
    context "No current user" do
      let(:user) { nil }

      it "redirects to sign_in page" do
        action
        expect(response).to redirect_to(zendesk_sign_in_path)
      end
    end

    context "User is not an admin" do
      let(:role) { "agent" }

      it "redirects to sign_in page if not an admin" do
        action
        expect(flash[:alert])
          .to eq("You are not authorized to access that page")
      end
    end

    context "User is an admin" do
      let(:role) { "admin" }

      it "successfully renders" do
        action
        expect(response).to be_successful
      end
    end
  end

  describe "#index" do
    it_behaves_like "requires Zendesk admin" do
      let(:action) { get :index }
    end

    context "viewing the table list" do
      render_views
      let!(:extract) { AnonymizedIntakeCsvService.new.store_csv }
      it "renders a table with extract filenames" do
        get :index
        expect(assigns[:extracts]).to include(extract)
        filename = extract.upload.attachment.filename.to_s
        expect(response.body).to match(filename)
      end
    end
  end

  describe "#show" do
    let(:extract) { AnonymizedIntakeCsvService.new.store_csv }
    it_behaves_like "requires Zendesk admin" do
      let(:action) { get :show, params: { id: extract.id } }
    end

    it "sends the csv file as a download attachment" do
      get :show, params: { id: extract.id }
      expect(response.headers["Content-Type"]).to eq("text/csv")
      expect(response.headers["Content-Disposition"]).to include("attachment")
    end
  end
end

