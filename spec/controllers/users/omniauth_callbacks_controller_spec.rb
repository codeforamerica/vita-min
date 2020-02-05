require "rails_helper"

RSpec.describe Users::OmniauthCallbacksController do
  describe "#idme" do
    let(:auth) { OmniAuth::AuthHash.new({}) }

    before do
      request.env["omniauth.auth"] = auth
      request.env["devise.mapping"] = Devise.mappings[:user]
    end

    context "when a user successfully authenticates through ID.me" do
      before do
        allow(User).to receive(:from_omniauth).with(auth).and_return user
      end

      context "with a returning ID.me user" do
        let(:user) { create :user, sign_in_count: 1 }

        it "signs the user in and redirects them to the overview page and sets success flash message" do
          get :idme
          expect(subject.current_user).to eq user
          expect(response).to redirect_to(overview_questions_path)
        end

        it "does not create a new Intake" do
          expect {
            get :idme
          }.not_to change(Intake, :count)
        end

        it "increments user sign_in_count by 1" do
          get :idme
          expect(user.sign_in_count).to eq 2
        end
      end

      context "with a new ID.me user" do
        let(:user) { build :user }

        it "saves and signs the user in and sets a new user flash message" do
          expect {
            get :idme
          }.to change(User, :count).by(1)
          expect(subject.current_user).to eq user.reload
          expect(response).to redirect_to(overview_questions_path)
        end

        it "creates a new intake and links the user to it" do
          expect {
            get :idme
          }.to change(Intake, :count).by(1)

          intake = Intake.last
          expect(subject.current_intake).to eq intake
          expect(subject.current_intake).to eq user.reload.intake
        end

        it "increments user sign_in_count to 1" do
          get :idme
          expect(user.sign_in_count).to eq(1)
        end
      end
    end

    context "when authentication fails" do
      context "when a user denies access to their idme info" do
        before do
          request.env["omniauth.error.type"] = :access_denied
        end

        it "redirects to the offboarding page" do
          get :failure

          expect(response).to redirect_to(identity_needed_path)
        end
      end

      context "when a user signs out of ID.me through our app" do
        let(:params) do
          { logout: "success" }
        end

        before do
          request.env["omniauth.error.type"] = :invalid_credentials
        end

        it "redirects to root path" do
          get :failure, params: params

          expect(response).to redirect_to root_path
        end
      end

      context "when a user is verifying their spouse in the same session" do
        let(:params) do
          { logout: "primary" }
        end

        before do
          request.env["omniauth.error.type"] = :invalid_credentials
          allow(SecureRandom).to receive(:hex).and_return("1234")
        end

        it "redirects to ID.me authorization endpoint with necessary params" do
          get :failure, params: params

          expect(session["omniauth.state"]).to eq "1234"
          expect(response).to redirect_to %r(\Ahttps://api\.idmelabs\.com/oauth/authorize)
          redirect_params = Rack::Utils.parse_query(URI.parse(response.location).query)
          expect(redirect_params["state"]).to eq "1234"
          expect(redirect_params["scope"]).to eq "ial2"
          expect(redirect_params["response_type"]).to eq "code"
          expect(redirect_params["redirect_uri"]).to eq "http://test.host/users/auth/idme/callback?spouse=true"
          expect(redirect_params).to include "client_id"
        end
      end

      context "for all other errors" do
        before do
          request.env["omniauth.error.type"] = :csrf_detected
          request.env["omniauth.error"] = OmniAuth::Strategies::OAuth2::CallbackError.new(:csrf_detected, "CSRF detected")
        end

        it "raises the error" do
          expect do
            get :failure
          end.to raise_error(OmniAuth::Strategies::OAuth2::CallbackError)
        end

      end
    end
  end
end