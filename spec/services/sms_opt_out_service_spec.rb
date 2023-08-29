require 'rails_helper'

RSpec.describe SmsOptOutService do
  let(:incoming_sms_params) {
    {
      "OptOutType" => "Stop"
    }
  }

  describe "#is_opting_out" do
    it "confirms if the value is 'Stop'" do
      expect(described_class.is_opting_out(incoming_sms_params)).to be_truthy
    end

    it "rejects if the key isn't present" do
      expect(described_class.is_opting_out({})).to be_falsey
    end
  end

  describe '#perform' do
    let(:intake) { create(:intake, sms_notification_opt_in: "yes") }
    let(:client) { intake.client }

    context "with an incoming sms that requests an opt-out" do

      it "creates a system note" do
        expect {
          described_class.process(client: client, params: incoming_sms_params)
        }.to change(SystemNote, :count).to(1)
      end

      it "turns off the preference to get SMS notifications" do
        expect {
          described_class.process(client: client, params: incoming_sms_params)
          intake.reload
        }.to change(intake, :sms_notification_opt_in).to("no")
      end
    end

    context "with an incoming sms that does not request an opt-out" do
      let(:incoming_sms_params) {
        {}
      }

      it "does not create a system note" do
        expect {
          described_class.process(client: client, params: incoming_sms_params)
        }.not_to change(SystemNote, :count)
      end

      it "does not change SMS notification preferences" do
        expect {
          described_class.process(client: client, params: incoming_sms_params)
        }.not_to change(intake, :sms_notification_opt_in)
      end
    end
  end
end
