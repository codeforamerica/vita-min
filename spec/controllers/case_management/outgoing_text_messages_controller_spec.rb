require "rails_helper"

RSpec.describe CaseManagement::OutgoingTextMessagesController do
  describe "#create" do
    let(:vita_partner) { create :vita_partner }
    let(:client) { create :client, vita_partner: vita_partner, intake: create(:intake, sms_phone_number: "+15105551234", phone_number: "+15105551777") }
    let(:params) do
      {
        client_id: client.id,
        outgoing_text_message: {
          body: "This is an outgoing text"
        }
      }
    end

    before { allow(subject).to receive(:send_text_message) }

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :create

    context "as an authenticated user" do
      let(:user) { create :user, vita_partner: vita_partner }
      before { sign_in user }

      it "calls send_text_message with the right arguments and redirects to messages" do
        post :create, params: params

        expect(subject).to have_received(:send_text_message).with("This is an outgoing text")
        expect(response).to redirect_to(case_management_client_messages_path(client_id: client.id))
      end

      context "with a blank body" do
        let(:params) do
          {
            client_id: client.id,
            outgoing_text_message: {
              body: " \n\t"
            }
          }
        end

        it "doesn't call send_text_message but still redirects to messages" do
          post :create, params: params

          expect(subject).not_to have_received(:send_text_message)
          expect(response).to redirect_to(case_management_client_messages_path(client_id: client.id))
        end
      end
    end
  end
end
