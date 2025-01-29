require 'rails_helper'

RSpec.describe Questions::DemographicPrimaryRaceController do
  describe "#update" do
    let(:params) do
      { demographics_primary_race_form: { demographics_primary_race_white: "yes" } }
    end

    before do
      sign_in intake.client
    end

    context "for any intake" do
      before do
        allow(GenerateF13614cPdfJob).to receive(:perform_later)
      end

      let(:intake) { create :intake, sms_phone_number: "+15105551234", email_address: "someone@example.com", locale: "en", preferred_name: "Mona Lisa", client: client }
      let(:client) { create :client, tax_returns: [build(:gyr_tax_return, service_type: "online_intake")] }

      it "the model after_update when completed at changes should enqueue the creation of the 13614c document" do
        post :update, params: params

        expect(GenerateF13614cPdfJob).to have_received(:perform_later).with(intake.id)
      end
    end
  end

end
