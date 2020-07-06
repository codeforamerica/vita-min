require "rails_helper"

RSpec.describe Zendesk::AnonymizedIntakeCsvExtractsController do
  describe "#index" do
    let(:user) { create :user, provider: "zendesk", role: role }
    before { allow(subject).to receive(:current_user).and_return(user) }

    context "No current user" do
      let(:user) { nil }

      it "redirects to sign_in page" do
        get :index
        expect(response).to redirect_to(zendesk_sign_in_path)
      end
    end

    context "User is not an admin" do
      let(:role) { "agent" }

      it "redirects to sign_in page if not an admin" do
        get :index
        expect(response).to redirect_to(zendesk_sign_in_path)
      end
    end

    context "User is an admin" do
      let(:role) { "admin" }

      it "successfully renders" do
        get :index
        expect(response).to be_successful
      end
    end
  end
end

