require 'rails_helper'

RSpec.describe ClientChannel, type: :channel do
  let(:client) { create :client }
  let(:params) { { id: client.id }}

  it_behaves_like :a_channel_for_beta_testers, action: :subscribe

  context "as a beta tester" do
    before { connect_as(create :beta_tester) }

    context 'without params' do
      let(:params) { {} }

      it 'rejects subscription when there are no params' do
        subscribe params

        expect(subscription).to be_rejected
      end
    end

    context 'with valid params' do
      let(:client) { create(:client) }

      it 'subscribes to a client' do
        subscribe params

        expect(subscription).to be_confirmed
        expect(subscription).to have_stream_for(client)
      end
    end
  end
end
