require "rails_helper"

RSpec.describe GetPhoneMetadataJob, type: :job do
  include MockTwilio

  describe "#perform" do
    let(:client) { create(:client) }
    let!(:intake) { create :intake, client: client, phone_number: phone_number }
    let(:phone_number) { '+15554567899' }
    let(:fake_metadata) do
      {
        "mobile_network_code" => "800",
        "carrier_name" => "T-Mobile USA, Inc.",
        "error_code" => nil,
        "mobile_country_code" => "310",
        "type" => "mobile"
      }
    end

    context "when Twilio does not raise an exception" do
      before do
        allow(TwilioService).to receive(:get_metadata).with(phone_number: phone_number).and_return(fake_metadata)
      end

      it "returns the metadata associated with the phone number" do
        GetPhoneMetadataJob.perform_now(intake)

        expect(intake.phone_number_type).to eq 'mobile'
        expect(intake.phone_carrier).to eq 'T-Mobile USA, Inc.'
      end

      context "when the intake is missing a phone number" do
        let(:phone_number) { nil }

        it "does not call the API" do
          expect {
            GetPhoneMetadataJob.perform_now(intake)
          }.not_to change(intake, :phone_number_type)

          expect(TwilioService).not_to have_received(:get_metadata)
        end
      end
    end

    context "when Twilio raises an exception" do
      before do
        allow(Twilio::REST::Client).to receive(:new).and_raise(Twilio::REST::RestError.new(400, OpenStruct.new(body: {}, status_code: 21211)))
      end

      it "exits cleanly" do
        expect {
          GetPhoneMetadataJob.perform_now(intake)
        }.not_to change(intake, :phone_number_type)
      end
    end
  end
end
