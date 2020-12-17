require 'rails_helper'

RSpec.describe ClientChannel, type: :channel do
  let(:client) { create :client }
  let(:user) { create :user_with_org }
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
      let(:client) { create(:client, vita_partner: user.vita_partner) }

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
    end
  end
end
