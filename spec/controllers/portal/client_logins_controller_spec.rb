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
          portal_request_client_login_form: {
            email_address: "client@example.com",
            phone_number: ""
          }
        }
      end

      it "initiates the login request process background job and redirects to 'link sent' page" do
        post :create, params: params

        expect(response).to redirect_to login_link_sent_portal_client_logins_path
        expect(ClientLoginRequestJob).to have_been_enqueued
      end
    end

    context "with invalid params" do
      # render_views
      let(:params) do
        {
          portal_request_client_login_form: {
            email_address: "client@example",
            phone_number: ""
          }
        }
      end

      it "does not enqueue a client login request and renders new" do
        post :create, params: params

        expect(response).to render_template :new
        expect(ClientLoginRequestJob).not_to have_been_enqueued
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
    before do
      allow(Devise.token_generator).to receive(:generate).and_return(['raw_token', 'encrypted_token'])
      client.update(login_token: "encrypted_token")
    end

    let(:params) { { id: "raw_token" } }

    context "as an unauthenticated client" do
      context "with valid token" do
        before do
          allow(Devise.token_generator).to receive(:digest).and_return("encrypted_token")
        end

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

            expect(response).to redirect_to portal_account_locked_path
          end
        end
      end

      context "with invalid token" do
        before do
          allow(Devise.token_generator).to receive(:digest).and_return("nonmatching_token")
        end

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
    before do
      allow(Devise.token_generator).to receive(:generate).and_return(["raw_token", "encrypted_token"])
      client.update(login_token: "encrypted_token")
    end

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
        before do
          allow(Devise.token_generator).to receive(:digest).and_return("encrypted_token")
        end

        context "with a matching ssn/client ID" do
          let(:params) do
            {
              id: "raw_token",
              portal_client_login_form: {
                confirmation_number: client.id.to_s
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

              expect(response).to redirect_to portal_account_locked_path
            end
          end
        end

        context "without a matching ssn/client ID" do
          let(:params) do
            {
              id: "raw_token",
              portal_client_login_form: {
                confirmation_number: "0"
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

              expect(response).to redirect_to(portal_account_locked_path)
            end
          end
        end
      end

      context "with an invalid token" do
        before do
          allow(Devise.token_generator).to receive(:digest).and_return("other_token")
        end

        it "redirect to a page saying you need a new token" do
          post :update, params: { id: "invalid_token" }

          expect(response).to redirect_to(invalid_token_portal_client_logins_path)
        end
      end
    end
  end
end
