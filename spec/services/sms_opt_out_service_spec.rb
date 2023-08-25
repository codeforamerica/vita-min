require 'rails_helper'

RSpec.describe SmsOptOutService do
  describe "#is_opting_out" do
    it "determines if params are requested an opt-out" do
      expect(described_class.is_opting_out({"OptOutType" => "Stop"})).to be_truthy
    end
  end

  describe '#perform' do
    let(:intake) { create(:intake, sms_notification_opt_in: "yes") }
    let(:client) { intake.client }

    context "with an incoming sms that requests an opt-out" do
      let(:incoming_sms_params) {
        {
          "OptOutType" => "STOP"
        }
      }

      it "creates a system note" do
        expect {
          described_class.process(client, incoming_sms_params)
        }.to change(SystemNote, :count).to(1)
      end

      it "turns off the preference to get SMS notifications" do
        expect {
          described_class.process(client, incoming_sms_params)
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
          described_class.process(client, incoming_sms_params)
        }.not_to change(SystemNote, :count)
      end

      it "does not change SMS notification preferences" do
        expect {
          described_class.process(client, incoming_sms_params)
        }.not_to change(intake, :sms_notification_opt_in)
      end
    end
  end
end
