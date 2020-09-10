require "rails_helper"

RSpec.describe OutgoingEmailsController do
  describe "#create" do
    let(:client) { create :client }

    before do
      allow(subject).to receive(:current_user).and_return user
    end

    context "as an anonymous user" do
      let(:user) { nil }
      it "redirects to sign in" do
        post :create, params: { client_id: client.id, body: "hi client" }

        # maybe redirect to client show, and let client show redirect login with a helpful post-login url
        expect(response).to redirect_to zendesk_sign_in_path
      end
    end

    context "as an authenticated non-admin user" do
      let(:user) { build :user, provider: "zendesk", id: 1 }

      it "redirects to sign in" do
        post :create, params: { outgoing_email: {client_id: client.id, body: "hi client" } }

        expect(response).to redirect_to zendesk_sign_in_path
      end
    end

    context "as an authenticated admin user" do
      let(:user) { build :user, provider: "zendesk", role: "admin", id: 1 }
      let(:expected_time) { DateTime.new(2020, 9, 9) }

      context "with body & client_id" do
        let(:params) do
          { outgoing_email: { client_id: client.id, body: "hi client" } }
        end
        before { allow(DateTime).to receive(:now).and_return(expected_time) }

        it "creates an OutgoingEmail and redirects to client show", active_job: true do
          expect do
            post :create, params: params
          end.to change(OutgoingEmail, :count).from(0).to(1)
          outgoing_email = OutgoingEmail.last
          expect(outgoing_email.subject).to eq("Update from GetYourRefund")
          expect(outgoing_email.body).to eq("hi client")
          expect(outgoing_email.client).to eq client
          expect(outgoing_email.user).to eq user
          expect(outgoing_email.sent_at).to eq expected_time
          expect(response).to redirect_to client_path(id: client.id)
        end

        xcontext "for a non-english client" do
          let(:client) { create :client, locale: "es" }

          it "translates any default strings in the email" do
            post :create, params: params

            outgoing_email = OutgoingEmail.last
            expect(outgoing_email.subject).to eq "Actualización de GetYourRefund"
          end
        end
      end

      context "without body" do
        let(:params) do
          { outgoing_email: { client_id: client.id } }
        end

        it "sends no email & redirects to client show" do
          expect do
            post :create, params: params
          end.not_to change(OutgoingEmail, :count)

          expect(response).to redirect_to client_path(id: client.id)
        end
      end
    end
  end
end
