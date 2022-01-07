require "rails_helper"

RSpec.describe Questions::OptionalConsentController do
  let(:intake) { create :intake, preferred_name: "Ruthie Rutabaga" }
  let!(:tax_return) { create :tax_return, client: intake.client }

  before do
    sign_in intake.client
  end

  describe "#update" do
    context "with valid params" do
      let (:params) do
        {
          optional_consent_form: {
            disclose_consented: true,
            global_carryforward_consented: false,
            relational_efin_consented: true,
            use_consented: true,
          }
        }
      end
      let(:ip_address) { "127.0.0.1" }
      let(:user_agent) { "IceFerret" }
      let(:current_time) { DateTime.new(2021, 2, 23) }

      before do
        allow(DateTime).to receive(:now).and_return current_time
        request.remote_ip = ip_address
        request.user_agent = user_agent
      end

      it "saves the answer, along with a timestamp and ip address" do
        post :update, params: params

        intake.reload
        consent = intake.client.consent
        expect(consent.disclose_consented_at).to eq current_time
        expect(consent.global_carryforward_consented_at).to be_nil
        expect(consent.relational_efin_consented_at).to eq current_time
        expect(consent.use_consented_at).to eq current_time
        expect(consent.user_agent).to eq "IceFerret"
        expect(consent.ip).to eq "127.0.0.1"
      end
    end
  end

  describe "#after_update_success" do
    before do
      intake.client.update(consent: build(:consent))
    end

    it "enqueues a job to generate optional consent form" do
      expect(GenerateOptionalConsentPdfJob).to receive(:perform_later).with(intake.client.consent)

      subject.after_update_success
    end
  end
end
