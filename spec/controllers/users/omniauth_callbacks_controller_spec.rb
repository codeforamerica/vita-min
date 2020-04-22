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
      let(:intake_from_session) { create :intake }

      before do
        allow(User).to receive(:from_omniauth).with(auth).and_return user
        session[:intake_id] = intake_from_session.id
      end

      it "creates user, signs them in, and redirects to the consent page" do
        expect {
          get :idme
        }.to change(User, :count).by(1)
        expect(subject.current_user).to eq user.reload
        expect(response).to redirect_to(consent_questions_path)
      end

      it "links the user to the intake, source, and referrer in the session and removes intake id from session" do
        get :idme

        intake_from_session.reload
        expect(subject.current_intake).to eq intake_from_session
        expect(subject.current_intake).to eq user.reload.intake
        expect(session[:intake_id]).to be_nil
      end

      it "increments user sign_in_count to 1" do
        get :idme
        expect(user.sign_in_count).to eq(1)
      end

      it "does not redirect to the after_login URL" do
        get :idme, params: { after_login: "/documents/additional-documents" }
        expect(response).to redirect_to(consent_questions_path)
      end

      context "no intake id in session" do
        before do
          session[:intake_id] = nil
          session[:source] = "source_from_session"
          session[:referrer] = "referrer_from_session"
        end

        it "creates a new intake with source and referrer from session" do
          expect {
            get :idme
          }.to change(Intake, :count).by(1)

          new_intake = Intake.last
          expect(new_intake.source).to eq "source_from_session"
          expect(new_intake.referrer).to eq "referrer_from_session"
        end
      end
    end

    context "when any returning user authenticates" do
      let(:consented_to_service) { "yes" }
      let(:user) { create :user, sign_in_count: 1, consented_to_service: consented_to_service }
      let(:intake_from_session) { create :intake }

      before do
        allow(User).to receive(:from_omniauth).with(auth).and_return user
        session[:intake_id] = intake_from_session.id
      end

      it "signs the user in" do
        get :idme
        expect(subject.current_user).to eq user
      end

      context "intake from session is new (has no associated user)" do
        it "deletes the intake saved in the session and does not create a new intake" do
          expect {
            get :idme
          }.to change(Intake, :count).by(-1)

          expect(user.intake).not_to eq intake_from_session
          expect(Intake.exists?(intake_from_session.id)).to eq false
          expect(session[:intake_id]).to be_nil
        end
      end

      context "intake from session is has an associated user (and is therefore probably not new)" do
        let(:user) { create :user, sign_in_count: 1, consented_to_service: consented_to_service, intake: intake_from_session }

        it "does not delete the intake and does not create a new intake" do
          expect {
            get :idme
          }.not_to change(Intake, :count)

          expect(session[:intake_id]).to be_nil
        end
      end

      it "increments user sign_in_count by 1" do
        get :idme
        expect(user.sign_in_count).to eq 2
      end

      context "when the returning user previously consented" do
        let(:consented_to_service) { "yes" }

        it "redirects them to the welcome page" do
          get :idme

          expect(subject.current_user).to eq user
          expect(response).to redirect_to(mailing_address_questions_path)
        end
      end

      context "when the returning user has not yet consented" do
        let(:consented_to_service) { "unfilled" }

        it "redirects them to the consent page (not the after_login)" do
          get :idme, params: { after_login: "/documents/additional-documents" }

          expect(subject.current_user).to eq user
          expect(response).to redirect_to(consent_questions_path)
        end
      end

      context "when the returning user used a spouse registration link" do
        it "signs the user in, redirects them to the welcome page" do
          get :idme, params: { spouse: "true" }
          expect(subject.current_user).to eq user
          expect(response).to redirect_to(mailing_address_questions_path)
        end
      end

      context "when the returning user has a after_login param" do
        it "redirects them to the after_login" do
          get :idme, params: { after_login: "/documents/additional-documents" }

          expect(subject.current_user).to eq user
          expect(response).to redirect_to("/documents/additional-documents")
        end
      end
    end

    context "when a new spouse user authenticates" do
      let(:spouse_user) { build :user }
      let(:primary_user) { create :user }

      before do
        request.env["devise.mapping"] = Devise.mappings[:user]
        allow(User).to receive(:from_omniauth).with(auth).and_return spouse_user
      end

      context "when doing same-device authentication" do
        before do
          sign_in primary_user
        end

        it "creates is_spouse user and redirects to the spouse consent page, keeping primary signed in" do
          expect {
            get :idme, params: { spouse: "true" }
          }.to change(User, :count).by(1)
          expect(spouse_user.reload.is_spouse).to eq true
          expect(subject.current_user).to eq primary_user
          expect(response).to redirect_to(spouse_consent_questions_path)
        end

        it "links spouse user to primary user's intake" do
          get :idme, params: { spouse: "true" }
          expect(spouse_user.reload.intake).to eq primary_user.intake
        end
      end

      context "when using link to authenticate later" do
        before do
          session[:authenticate_spouse_only] = true
          session[:intake_id] = primary_user.intake.id
        end

        it "creates is_spouse user, signs them in, and redirects to the spouse consent page" do
          expect {
            get :idme, params: { spouse: "true" }
          }.to change(User, :count).by(1)
          expect(spouse_user.reload.is_spouse).to eq true
          expect(subject.current_user).to eq spouse_user
          expect(response).to redirect_to(spouse_consent_questions_path)
        end

        it "links spouse user to intake from session" do
          get :idme, params: { spouse: "true" }
          expect(spouse_user.reload.intake).to eq primary_user.intake
        end
      end
    end

    xcontext "when we expected a new spouse but the primary user authenticated instead" do
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

    context "when a spouse returns" do
      let(:spouse_consent) { "yes" }
      let(:spouse_user) { create :spouse_user, consented_to_service: spouse_consent }
      let(:primary_user) { create :user }
      before do
        sign_in spouse_user
        request.env["devise.mapping"] = Devise.mappings[:user]
        allow(User).to receive(:from_omniauth).with(auth).and_return spouse_user
      end

      context "and they have already consented" do
        let(:spouse_consent) { "yes" }

        it "redirects to the welcome spouse page" do
          get :idme

          expect(response).to redirect_to spouse_was_student_questions_path
        end
      end

      context "and they have not yet consented (not the after_login)" do
        let(:spouse_consent) { "unfilled" }

        it "redirects to the spouse consent page" do
          get :idme, params: { after_login: "/documents/additional-documents" }

          expect(response).to redirect_to spouse_consent_questions_path
        end
      end

      context "and they have a after_login param" do
        it "redirects them to the after_login" do
          get :idme, params: { after_login: "/documents/additional-documents" }

          expect(subject.current_user).to eq spouse_user
          expect(response).to redirect_to("/documents/additional-documents")
        end
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

        it "raises the error with details" do
          expect(Rails.logger).to receive(:error).with("OmniAuth::Strategies::OAuth2::CallbackError, csrf_detected, intake: ")
          expect do
            get :failure
          end.to raise_error(OmniAuth::Strategies::OAuth2::CallbackError)
        end
      end
    end
  end
end
