require "rails_helper"

RSpec.describe Users::OmniauthCallbacksController do
  describe "#zendesk" do
    let(:auth) { OmniAuth::AuthHash.new({}) }
    let(:user) { create :user, name: "Gwendolin Guava", email: "gguava@apple.orange" }

    before do
      request.env["omniauth.auth"] = auth
      request.env["devise.mapping"] = Devise.mappings[:user]
      allow(User).to receive(:from_zendesk_oauth).and_return user
    end

    it "signs in the user" do
      expect do
        get :zendesk
      end.to change(subject, :current_user).from(nil).to(user)
    end

    context "with post-login path to redirect to" do
      before { session[:after_login_path] = "/faq" }

      it "redirects the user to the login path and clears it from the session" do
        get :zendesk
        expect(response).to redirect_to("/faq")
        expect(session[:after_login_path]).to eq nil
      end
    end

    context "without a path to redirect to" do
      it "redirects to root with a flash message" do
        get :zendesk

        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq "Signed in as Gwendolin Guava, gguava@apple.orange"
      end
    end
  end

  describe "#failure" do
    before do
      request.env["devise.mapping"] = Devise.mappings[:user]
    end

    context "when authentication fails" do
      context "when a user denies access to their info" do
        before do
          request.env["omniauth.error.type"] = :access_denied
        end

        it "redirects to root path with an alert" do
          get :failure

          expect(response).to redirect_to(root_path)
          expect(flash[:alert]).to eq "We were not able to verify your Zendesk account."
        end
      end

      context "for all other errors" do
        before do
          request.env["omniauth.error.type"] = :csrf_detected
          request.env["omniauth.error"] = OmniAuth::Strategies::OAuth2::CallbackError.new(:csrf_detected, "CSRF detected")
        end

        it "raises the error with details" do
          expect do
            get :failure
          end.to raise_error(OmniAuth::Strategies::OAuth2::CallbackError)
        end
      end
    end
  end
end
