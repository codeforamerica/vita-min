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

  describe "#new" do
    it "returns 200 OK" do
      get :new

      expect(response).to be_ok
    end

    context "as an authenticated client" do
      before { sign_in client }

      it "redirects to client portal home" do
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

        it "enqueues an email login request job with the right data and redirects to 'link sent' page" do
          post :create, params: params

          expect(response).to redirect_to login_link_sent_portal_client_logins_path(locale: "es")
          expect(ClientEmailLoginRequestJob).to have_been_enqueued.with(
            email_address: "client@example.com",
            locale: :es,
            visitor_id: "visitor id"
          )
        end
      end

      context "with an SMS phone number" do
        let(:contact_info_params) do
          {
            email_address: nil,
            sms_phone_number: " (510) 555 1234"
          }
        end

        it "enqueues a text message login request job with the right data and redirects to 'link sent' page" do
          post :create, params: params

          expect(response).to redirect_to login_link_sent_portal_client_logins_path(locale: "es")
          expect(ClientTextMessageLoginRequestJob).to have_been_enqueued.with(
            sms_phone_number: "+15105551234",
            locale: :es,
            visitor_id: "visitor id"
          )
        end
      end

      context "saving contact info to session" do
        context "with an email address" do
          let(:contact_info_params) do
            {
              email_address: "client@example.com",
              sms_phone_number: nil
            }
          end

          it "adds it" do
            post :create, params: params
            expect(session[:email_address]).to eq(params[:portal_request_client_login_form][:email_address])
          end
        end

        context "with a phone number" do
          let(:contact_info_params) do
            {
              email_address: nil,
              sms_phone_number: "4155537865"
            }
          end

          it "adds it" do
            post :create, params: params
            expect(session[:sms_phone_number]).to eq("+14155537865")
          end
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
        expect(ClientEmailLoginRequestJob).not_to have_been_enqueued
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

        it "redirects to a page saying you need a new token" do
          get :edit, params: { id: "invalid_token" }

          expect(response).to redirect_to(invalid_token_portal_client_logins_path)
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

        it "redirect to a page saying you need a new token" do
          post :update, params: { id: "invalid_token" }

          expect(response).to redirect_to(invalid_token_portal_client_logins_path)
        end
      end
    end
  end

  describe "#link_sent" do
    context "moving contact info from the session to an instance variable" do
      context "with an email address" do
        before do
          session[:email_address] = "moveabletypo@example.com"
        end

        it "removes it from the session and saves it to a variable" do
          get :link_sent

          expect(session[:email_address]).to be_nil
          expect(assigns(:email_address)).to eq "moveabletypo@example.com"
        end
      end
      context "with an sms phone number" do
        before do
          session[:sms_phone_number] = "+14155537865"
        end

        it "removes it from the session and saves it to a variable" do
          get :link_sent

          expect(session[:sms_phone_number]).to be_nil
          expect(assigns(:sms_phone_number)).to eq "+14155537865"
        end
      end
    end
  end
end
