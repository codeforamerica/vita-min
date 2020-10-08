require "rails_helper"

RSpec.describe CaseManagement::OutgoingEmailsController do
  describe "#create" do
    let(:client) { create :client }
    let(:params) do
      { client_id: client.id, outgoing_email: { body: "hi client" } }
    end

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :create
    it_behaves_like :a_post_action_for_beta_testers_only, action: :create

    context "as an authenticated admin user" do
      let(:expected_time) { DateTime.new(2020, 9, 9) }
      let(:beta_user) { create :beta_tester }
      before { sign_in beta_user }

      context "with body & client_id" do
        let(:params) do
          {
            client_id: client.id,
            outgoing_email: {
              body: "hi client",
              attachment: fixture_file_upload("attachments/test-pattern.png")
            }
          }
        end
        before { allow(DateTime).to receive(:now).and_return(expected_time) }

        it "creates an OutgoingEmail, asks it to deliver itself later, then redirects to client show", active_job: true do
          expect do
            post :create, params: params
          end.to change(OutgoingEmail, :count).from(0).to(1).and have_enqueued_mail(OutgoingEmailMailer, :user_message)
          outgoing_email = OutgoingEmail.last
          expect(outgoing_email.subject).to eq("Update from GetYourRefund")
          expect(outgoing_email.body).to eq("hi client")
          expect(outgoing_email.client).to eq client
          expect(outgoing_email.user).to eq beta_user
          expect(outgoing_email.sent_at).to eq expected_time
          expect(outgoing_email.to).to eq client.email_address
          expect(outgoing_email.attachment).to be_present
          expect(response).to redirect_to case_management_client_messages_path(client_id: client.id)
        end
      end

      context "without body" do
        let(:params) do
          { client_id: client.id, outgoing_email: { body: " " } }
        end

        it "sends no email & redirects to client show" do
          expect do
            post :create, params: params
          end.not_to change(OutgoingEmail, :count)

          expect(response).to redirect_to case_management_client_messages_path(client_id: client.id)
        end
      end
    end
  end
end
