require "rails_helper"

RSpec.describe OptionalConsentForm do
  let(:intake) { create :intake }
  let(:params) do
    {
      disclose_consented: "true",
      global_carryforward_consented: "true",
      relational_efin_consented: "false",
      use_consented: "true",
    }
  end

  describe "#save" do
    let(:current_time) { DateTime.new(2025, 2, 7, 11, 10, 1) }
    before do
      allow(DateTime).to receive(:now).and_return current_time
    end

    context "when there is no consent object" do
      it "creates a new consent record and saves the fields to it" do
        form = OptionalConsentForm.new(intake, params)
        expect {
          form.save
        }.to change(Consent, :count).by(1)

        intake.reload
        consent = intake.client.consent
        expect(consent.disclose_consented_at).to eq current_time
        expect(consent.global_carryforward_consented_at).to eq current_time
        expect(consent.relational_efin_consented_at).to be_nil
        expect(consent.use_consented_at).to eq current_time
      end
    end

    # TODO: is this the right behavior?
    context "when there is already a consent object" do
      let(:previous_time) { DateTime.new(2021, 2, 7, 11, 10, 1) }
      before do
        intake.client.create_consent({
          disclose_consented_at: previous_time,
          global_carryforward_consented_at: previous_time,
          relational_efin_consented_at: previous_time,
          use_consented_at: previous_time,
        })
      end

      it "overwrites the existing consent record" do
        form = OptionalConsentForm.new(intake, params)
        expect {
          form.save
        }.not_to change(Consent, :count)

        intake.reload
        consent = intake.client.consent
        expect(consent.disclose_consented_at).to eq current_time
        expect(consent.global_carryforward_consented_at).to eq current_time
        expect(consent.relational_efin_consented_at).to be_nil
        expect(consent.use_consented_at).to eq current_time
      end
    end
  end
end