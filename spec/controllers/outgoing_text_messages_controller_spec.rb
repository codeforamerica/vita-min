require "rails_helper"

RSpec.describe OutgoingTextMessagesController do
  describe "#update" do
    let!(:existing_message) { create :outgoing_text_message }

    context "with an invalid request" do
      before do
        allow(TwilioService).to receive(:valid_request?).and_return false
      end

      it "returns a 403 status code" do
        post :update, params: { id: existing_message.id }

        expect(response.status).to eq 403
      end
    end

    context "with a valid request" do
      let(:params) do
        {
          "SmsSid" => "SM86006fa9b56c465597ce14349as6s7a2",
          "SmsStatus" => "delivered",
          "MessageStatus" => "delivered",
          "To" => "+14083483513",
          "MessageSid" => "SM86006fa9b56c465597ce14987a3f85a2",
          "AccountSid" => "AC70b4e3aa44fe96139823d8f00a46fre7",
          "From" => "+15136133299",
          "ApiVersion" => "2010-04-01",
          "id" => existing_message.id
        }
      end
      before do
        allow(TwilioService).to receive(:valid_request?).and_return true
      end

      it "updates the status of the existing message" do
        post :update, params: params

        expect(response).to be_ok
        expect(existing_message.reload.twilio_status).to eq "delivered"
      end
    end
  end
end
