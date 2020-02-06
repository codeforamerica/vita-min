require "rails_helper"

RSpec.describe Users::OmniauthCallbacksController do
  describe "#idme" do
    let(:auth) { OmniAuth::AuthHash.new({}) }

    before do
      request.env["omniauth.auth"] = auth
      request.env["devise.mapping"] = Devise.mappings[:user]
    end

    context "when a new primary user authenticates" do
      let(:user) { build :user }

      before do
        allow(User).to receive(:from_omniauth).with(auth).and_return user
        session[:source] = "source_from_session"
        session[:referrer] = "referrer_from_session"
      end

      it "creates user, signs them in, and redirects to the welcome page" do
        expect {
          get :idme
        }.to change(User, :count).by(1)
        expect(subject.current_user).to eq user.reload
        expect(response).to redirect_to(welcome_questions_path)
      end

      it "creates a new intake and links the user to it" do
        expect {
          get :idme
        }.to change(Intake, :count).by(1)

        intake = Intake.last
        expect(subject.current_intake).to eq intake
        expect(subject.current_intake).to eq user.reload.intake
        expect(intake.source).to eq "source_from_session"
        expect(intake.referrer).to eq "referrer_from_session"
      end

      it "increments user sign_in_count to 1" do
        get :idme
        expect(user.sign_in_count).to eq(1)
      end
    end

    context "when any returning user authenticates" do
      let(:user) { create :user, sign_in_count: 1 }

      before do
        allow(User).to receive(:from_omniauth).with(auth).and_return user
      end

      it "signs the user in, redirects them to the welcome page" do
        get :idme
        expect(subject.current_user).to eq user
        expect(response).to redirect_to(welcome_questions_path)
      end

      it "does not create a new intake" do
        expect {
          get :idme
        }.not_to change(Intake, :count)
      end

      it "increments user sign_in_count by 1" do
        get :idme
        expect(user.sign_in_count).to eq 2
      end

      context "when the returning user used a spouse registration link" do
        it "signs the user in, redirects them to the welcome page" do
          get :idme, params: { spouse: "true" }
          expect(subject.current_user).to eq user
          expect(response).to redirect_to(welcome_questions_path)
        end
      end
    end

    context "when a new spouse user authenticates" do
      let(:spouse_user) { build :user }
      let(:primary_user) { create :user }

      before do
        sign_in primary_user
        request.env["devise.mapping"] = Devise.mappings[:user]
        allow(User).to receive(:from_omniauth).with(auth).and_return spouse_user
      end

      it "creates is_spouse user and redirects to the welcome spouse page, keeping primary signed in" do
        expect {
          get :idme, params: { spouse: "true" }
        }.to change(User, :count).by(1)
        expect(spouse_user.reload.is_spouse).to eq true
        expect(subject.current_user).to eq primary_user
        expect(response).to redirect_to(welcome_spouse_questions_path)
      end

      it "links spouse user to primary user's intake" do
        get :idme, params: { spouse: "true" }
        expect(spouse_user.reload.intake).to eq primary_user.intake
      end
    end

    context "when we expected a new spouse but the primary user authenticated instead" do
      let(:primary_user) { create :user }

      before do
        sign_in primary_user
        request.env["devise.mapping"] = Devise.mappings[:user]
        allow(User).to receive(:from_omniauth).with(auth).and_return primary_user
      end

      it "redirects to spouse identity page with a 'missing_spouse' param" do
        get :idme, params: { spouse: "true" }

        expect(response).to redirect_to spouse_identity_questions_path(missing_spouse: "true")
      end

      it "does not create a new intake" do
        expect do
          get :idme, params: { spouse: "true" }
        end.not_to change(Intake, :count)
      end

      it "does not sign in the primary user again" do
        expect do
          get :idme, params: { spouse: "true" }
        end.not_to change(primary_user, :sign_in_count)
      end
    end
  end

  describe "#failure" do
    before do
      request.env["devise.mapping"] = Devise.mappings[:user]
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