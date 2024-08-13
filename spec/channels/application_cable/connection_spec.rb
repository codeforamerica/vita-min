require 'rails_helper'

RSpec.describe ApplicationCable::Connection, type: :channel do
  let(:env)     { instance_double('env') }

  before do
    allow_any_instance_of(ApplicationCable::Connection).to receive(:env).and_return(env)
    allow(env).to receive(:[]).with('warden').and_return(warden)
  end

  context "with logged-in user" do
    let(:warden)  { instance_double('warden', user: user) }
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
        expect { connect "/cable" }.not_to raise_error
        expect(connection.current_user).to eq(nil)

        expect(@emit_point_params).to eq([
          ["vita-min.dogapi.application_cable.uncaught_throw_warden_error", 1, {:tags=>["env:test"], :type=>"count"}]
        ])
      end
    end
  end

  context "with a state intake" do
    let(:warden) { warden_ = instance_double("warden") }

    before do
      StateFile::StateInformationService.active_state_codes.excluding(state_code).each do |other_state_code|
        allow(warden).to receive(:user).with("state_file_#{other_state_code}_intake").and_return(nil)
      end
      allow(warden).to receive(:user).with(:state_file_az_intake).and_return(intake)
    end

    StateFile::StateInformationService.active_state_codes.each do |state_code|
      let(:state_code) { state_code }
      let(:intake) { create("state_file_#{state_code}_intake".to_sym) }

      it "successfully connects" do
        expect { connect "/cable" }.not_to raise_error
        expect(connection.current_state_file_intake).to eq(intake)
      end
    end
  end
end
