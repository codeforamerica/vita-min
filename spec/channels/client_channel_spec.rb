require 'rails_helper'

RSpec.describe ClientChannel, type: :channel do
  let(:client) { create :client }
  let(:user) { create :organization_lead_user }
  let(:params) { { id: client.id } }

  context "as an unauthenticated user" do
    before { connect_as(nil) }

    it "rejects the subscription" do
      subscribe params

      expect(subscription).to be_rejected
    end
  end

  context "as an authenticated user" do
    before { connect_as(user) }

    context 'without params' do
      let(:params) { {} }

      it 'rejects subscription when there are no params' do
        subscribe params

        expect(subscription).to be_rejected
      end
    end

    context 'with valid params' do
      let(:client) { create(:client, vita_partner: user.role.organization) }

      it 'subscribes to a client' do
        subscribe params

        expect(subscription).to be_confirmed
        expect(subscription).to have_stream_for(client)
      end
    end
  end

  describe ".broadcast_contact_record" do
    context "publishing a message" do
      let!(:outgoing_text_message) { create(:outgoing_text_message) }

      before do
        allow(ApplicationController).to receive(:render).and_return("template output")
      end

      it "renders the message partial with the message" do
        expect do
          ClientChannel.broadcast_contact_record(outgoing_text_message)
        end.to have_broadcasted_to(ClientChannel.broadcasting_for(outgoing_text_message.client)).with(["template output"])
        expect(ApplicationController).to have_received(:render).with hash_including(locals: { contact_record: outgoing_text_message })
      end

      context "when the rendered template is too long for Postgres" do
        let(:message) { "X" * 8001 }
        before do
          allow(ApplicationController).to receive(:render).and_return(message)
          allow(I18n).to receive(:t).with("hub.client_channel.please_reload_html").and_return("Plz reload")
          allow(described_class).to receive(:broadcast_to).and_call_original
          allow(described_class).to receive(:broadcast_to).with(outgoing_text_message.client, [message]).and_raise(PG::InvalidParameterValue)
        end

        it "renders the a note saying the user should reload the page" do
          expect do
            ClientChannel.broadcast_contact_record(outgoing_text_message)
          end.to have_broadcasted_to(ClientChannel.broadcasting_for(outgoing_text_message.client)).with(["Plz reload"])
          expect(ApplicationController).to have_received(:render).with hash_including(locals: { contact_record: outgoing_text_message })
        end
      end
    end
  end
end
