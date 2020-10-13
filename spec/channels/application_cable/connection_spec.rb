require 'rails_helper'

RSpec.describe ApplicationCable::Connection, type: :channel do
  let(:env)     { instance_double('env') }
  let(:warden)  { instance_double('warden', user: user) }

  before do
    allow_any_instance_of(ApplicationCable::Connection).to receive(:env).and_return(env)
    allow(env).to receive(:[]).with('warden').and_return(warden)
  end

  context "with no logged-in user" do
    let(:user) { nil }

    it "rejects the connection" do
      expect { connect "/cable" }.to have_rejected_connection
    end
  end

  context "with logged-in user" do
    let(:user) { create(:user) }

    it "successfully connects" do
      expect { connect "/cable" }.not_to raise_error
      expect(connection.current_user).to eq(user)
    end
  end
end
