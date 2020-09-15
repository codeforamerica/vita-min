require "rails_helper"

RSpec.describe UsersController do
  describe "#profile" do
    before do
      allow(subject).to receive(:current_user).and_return user
    end

    context "without an authenticated user" do
      let(:user) { nil }

      it "redirects to Zendesk login" do
        get :profile

        expect(response).to redirect_to zendesk_sign_in_path
        expect(session[:after_login_path]).to be_present
      end
    end

    context "with an authenticated user" do
      context "who is not an admin" do
        let(:user) { create :user }

        it "returns 403" do
          get :profile

          expect(response.status).to eq 403
        end
      end

      context "who is an admin" do
        render_views
        let(:user) { create :user, role: "admin", name: "Adam Avocado" }

        it "renders information about the current user" do
          get :profile

          expect(response).to be_ok
          expect(response.body).to have_content "Adam Avocado"
        end
      end
    end
  end
end