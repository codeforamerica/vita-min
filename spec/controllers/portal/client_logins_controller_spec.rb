require "rails_helper"

RSpec.describe Portal::ClientLoginsController, type: :controller do
  let(:client) do
    create(
      :client,
      intake: create(
        :intake,
        email_address: "client@example.com",
        sms_phone_number: "+15105551234"
      )
    )
  end
  let(:client_query) { Client.where(id: client) }

  before do
    allow(DatadogApi).to receive(:increment)
  end

  describe "#new" do
    it "returns 200 OK" do
      get :new

      expect(response).to be_ok
    end

    context "as an authenticated client" do
      before { sign_in client }

      it "redirects to client portal home by default" do
        get :new

        expect(response).to redirect_to portal_root_path
      end
    end
  end

  describe "#create", active_job: true do
    context "with valid params" do
      let(:params) do
        {
          locale: "es",
          portal_request_client_login_form: contact_info_params
        }
      end
      before { allow(subject).to receive(:visitor_id).and_return "visitor id" }

      context "with an email address" do
        let(:contact_info_params) do
          {
            email_address: "client@example.com",
            sms_phone_number: nil
          }
        end

        it "enqueues an email login request job with the right data and asks for verification code" do
          post :create, params: params

          expect(ClientEmailVerificationRequestJob).to have_been_enqueued.with(
            email_address: "client@example.com",
            locale: :es,
            visitor_id: "visitor id"
          )
          expect(response).to be_ok
          expect(response).to render_template(:enter_verification_code)
        end
      end

      context "with an SMS phone number" do
        let(:contact_info_params) do
          {
            email_address: nil,
            sms_phone_number: " (510) 555 1234"
          }
        end

        it "enqueues a text message login request job with the right data and renders the 'enter verification code' page" do
          post :create, params: params

          expect(ClientTextMessageVerificationRequestJob).to have_been_enqueued.with(
            sms_phone_number: "+15105551234",
            locale: :es,
            visitor_id: "visitor id"
          )
          expect(response).to be_ok
          expect(response).to render_template(:enter_verification_code)
        end
      end
    end

    context "with invalid params" do
      let(:params) do
        {
          portal_request_client_login_form: {
            email_address: "client@example",
            sms_phone_number: ""
          }
        }
      end

      it "does not enqueue a client login request and renders new" do
        post :create, params: params

        expect(response).to render_template :new
        expect(ClientEmailVerificationRequestJob).not_to have_been_enqueued
      end
    end

    context "as an authenticated client" do
      before { sign_in client }

      it "redirects to client portal home" do
        post :create, params: {}

        expect(response).to redirect_to portal_root_path
      end
    end
  end

  describe "#edit" do
    let(:params) { { id: "raw_token" } }

    context "as an unauthenticated client" do
      context "with valid token" do
        before { allow(ClientLoginsService).to receive(:clients_for_token).and_return(client_query) }

        it "it is ok" do
          get :edit, params: params

          expect(response).to be_ok
        end

        context "when the client account is locked" do
          before do
            client.lock_access!
          end

          it "redirects to the lockout page" do
            get :edit, params: params

            expect(response).to redirect_to account_locked_portal_client_logins_path
          end
        end
      end

      context "with invalid token" do
        before { allow(ClientLoginsService).to receive(:clients_for_token).and_return(Client.none) }

        it "redirects to the portal login page" do
          get :edit, params: { id: "invalid_token" }

          expect(response).to redirect_to(portal_client_logins_path)
        end
      end
    end

    context "as an authenticated client" do
      before do
        sign_in(client)
      end

      it "redirects to client portal" do
        get :edit, params: params

        expect(response).to redirect_to(portal_root_path)
      end
    end
  end

  describe "#update" do
    let(:params) { { id: "raw_token", client_id: client.id } }

    context "as an authenticated client" do
      before { sign_in client }

      it "redirects to client portal home" do
        post :update, params: params

        expect(response).to redirect_to portal_root_path
      end
    end

    context "as an unauthenticated client" do
      context "with a valid token" do
        before { allow(ClientLoginsService).to receive(:clients_for_token).and_return(client_query) }

        context "with a matching ssn/client ID" do
          let(:params) do
            {
              id: "raw_token",
              portal_client_login_form: {
                last_four_or_client_id: client.id.to_s
              }
            }
          end

          it "signs in the client and redirects to portal home" do
            post :update, params: params

            expect(subject.current_client).to eq(client)
            expect(response).to redirect_to portal_root_path
          end

          context "when the client was trying to access a protected page" do
            let(:original_path) { "/portal/fake-page?test=1234" }
            let(:params) do
              {
                id: "raw_token",
                portal_client_login_form: {
                  last_four_or_client_id: client.id.to_s,
                }
              }
            end

            before do
              session[:after_client_login_path] = original_path
            end

            it "redirects to that page and removes the path from the session" do
              post :update, params: params

              expect(response).to redirect_to original_path
              expect(session).not_to include :after_client_login_path
            end
          end

          context "when a client is locked out" do
            before do
              client.lock_access!
            end

            it "redirects to an account-locked page" do
              post :update, params: params

              expect(response).to redirect_to account_locked_portal_client_logins_path
            end
          end
        end

        context "without a matching ssn/client ID" do
          let(:params) do
            {
              id: "raw_token",
              portal_client_login_form: {
                last_four_or_client_id: "0"
              }
            }
          end

          render_views

          it "renders the :edit template and increments a lockout number" do
            expect do
              post :update, params: params
            end.to change { client.reload.failed_attempts }.by 1

            expect(subject.current_client).to eq(nil)
            expect(response).to render_template(:edit)
          end

          context "with 4 previous failed attempts" do
            before do
              client.update(failed_attempts: 4)
            end

            it "locks the client account and redirects to a lockout page" do
              expect do
                post :update, params: params
              end.to change { client.reload.failed_attempts }.by 1
              expect(client.reload.access_locked?).to be_truthy

              expect(response).to redirect_to(account_locked_portal_client_logins_path)
            end
          end
        end
      end

      context "with an invalid token" do
        before { allow(ClientLoginsService).to receive(:clients_for_token).and_return(Client.none) }

        it "redirects to the portal login page" do
          post :update, params: { id: "invalid_token" }

          expect(response).to redirect_to(portal_client_logins_path)
        end
      end
    end
  end

  describe "#check_verification_code" do
    context "with valid params" do
      let(:email_address) { "example@example.com" }
      let(:verification_code) { "000004" }
      let(:hashed_verification_code) { "hashed_verification_code" }
      let(:params) { { portal_verification_code_form: {
        contact_info: email_address,
        verification_code: verification_code
      }}}
      let(:client) { create(:client) }

      before do
        allow(VerificationCodeService).to receive(:hash_verification_code_with_contact_info).with(email_address, verification_code).and_return(hashed_verification_code)
        allow(ClientLoginsService).to receive(:clients_for_token).with(hashed_verification_code).and_return(Client.where(id: client))
      end

      it "redirects to the next page for login" do
        post :check_verification_code, params: params
        expect(response).to redirect_to(edit_portal_client_login_path(id: hashed_verification_code))
      end

      context "Datadog" do
        it "increments a counter" do
          post :check_verification_code, params: params
          expect(DatadogApi).to have_received(:increment).with("client_logins.verification_codes.right_code")
        end
      end
    end

    context "with invalid params" do
      context "with clients matching the contact info but invalid verification code" do
        let(:email_address) { "example@example.com" }
        let(:wrong_verification_code) { "000005" }
        let(:hashed_wrong_verification_code) { "hashed_wrong_verification_code" }
        let(:params) { { portal_verification_code_form: {
          contact_info: email_address,
          verification_code: wrong_verification_code,
        }}}
        let!(:client) { create(:intake, email_address: email_address).client }

        before do
          allow(VerificationCodeService).to receive(:hash_verification_code_with_contact_info).with(email_address, wrong_verification_code).and_return(hashed_wrong_verification_code)
          allow(ClientLoginsService).to receive(:clients_for_token).with(hashed_wrong_verification_code).and_return(Client.none)
        end

        it "increments their lockout counter & shows an error in the form" do
          expect {
            post :check_verification_code, params: params
          }.to change { client.reload.failed_attempts }

          expect(response).to be_ok
          expect(assigns[:verification_code_form]).to be_present
          expect(assigns[:verification_code_form].errors).to include(:verification_code)
        end

        context "Datadog" do
          it "increments a counter" do
            post :check_verification_code, params: params
            expect(DatadogApi).to have_received(:increment).with("client_logins.verification_codes.wrong_code")
          end
        end
      end

      context "with clients matching the contact info & token but locked out" do
        let(:email_address) { "example@example.com" }
        let(:wrong_verification_code) { "000005" }
        let(:params) { { portal_verification_code_form: {
          contact_info: email_address,
          verification_code: wrong_verification_code,
        }}}
        let!(:client) { create(:client, intake: create(:intake, email_address: email_address), locked_at: DateTime.now) }

        it "redirects to the account locked page" do
          post :check_verification_code, params: params

          expect(response).to redirect_to(account_locked_portal_client_logins_path)
        end
      end

      context "with blank contact info" do
        let(:params) { { portal_verification_code_form: {
          contact_info: "",
          verification_code: "999999",
        }} }

        it "shows a Bad Request error" do
          post :check_verification_code, params: params
          expect(response.status).to eq(400)
        end
      end

      context "with invalid data in the verification code" do
        let(:email_address) { "example@example.com" }
        let!(:client) { create(:intake, email_address: email_address).client }
        let(:params) { { portal_verification_code_form: {
          contact_info: email_address,
          verification_code: "invalid",
        }}}

        it "re-renders the form with errors and does not increment lockout counter" do
          expect { post :check_verification_code, params: params }.not_to change { client.reload.failed_attempts }
          expect(response).to be_ok
          expect(assigns[:verification_code_form].errors).to include(:verification_code)
        end
      end

      context "with no clients matching the contact info" do
        let(:email_address) { "example@example.com" }
        let(:verification_code) { "000004" }
        let(:hashed_verification_code) { "hashed_verification_code" }

        before do
          allow(VerificationCodeService).to receive(:hash_verification_code_with_contact_info).with(email_address, verification_code).and_return(hashed_verification_code)
          allow(ClientLoginsService).to receive(:clients_for_token).with(hashed_verification_code).and_return(Client.none)
        end

        let(:params) { { portal_verification_code_form: {
          contact_info: email_address,
          verification_code: verification_code
        }}}

        it "renders the page with an error in the verification code field" do
          post :check_verification_code, params: params
          expect(response).to be_ok
          expect(assigns[:verification_code_form]).to be_present
          expect(assigns[:verification_code_form].errors).to include(:verification_code)
        end
      end
    end
  end
end
