require 'rails_helper'

RSpec.describe ApplicationCable::Connection, type: :channel do
  let(:env)     { instance_double('env') }
  let(:warden)  { instance_double('warden', user: user) }

  before do
    allow_any_instance_of(ApplicationCable::Connection).to receive(:env).and_return(env)
    allow(env).to receive(:[]).with('warden').and_return(warden)
  end

  context "with logged-in user" do
    let(:user) { create(:user) }

    it "successfully connects" do
      expect { connect "/cable" }.not_to raise_error
      expect(connection.current_user).to eq(user)
    end

    context 'if an UncaughtThrowError occurs' do
      include MockDogapi

      before do
        enable_datadog_and_stub_emit_point
        allow(warden).to receive(:user) do
          throw :warden
        end
      end

      it "avoids the crash and increments a datadog metric" do
        expect { connect("/cable").current_user }.to raise_error(ActionCable::Connection::Authorization::UnauthorizedError)

        expect(@emit_point_params).to eq([
                                           ["vita-min.dogapi.application_cable.uncaught_throw_warden_error", 1, {:tags=>["env:test"], :type=>"count"}]
                                         ])
      end
    end
  end
end
