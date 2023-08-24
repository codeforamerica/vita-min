require 'rails_helper'

RSpec.describe GenerateOptionalConsentPdfJob, type: :job do
  describe "#perform" do
    let(:consent) { create(:consent, client: create(:client, intake: build(:intake))) }

    before do
      allow(consent).to receive(:update_or_create_optional_consent_pdf).and_call_original
      allow(consent).to receive(:update_or_create_f15080_vita_disclosure_pdf).and_call_original
    end

    it "creates a optional consent PDF" do
      subject.perform(consent)

      expect(consent).to have_received(:update_or_create_optional_consent_pdf)
    end

    context "disclose_consented_at is present" do
      it "calls update_or_create_f15080_vita_disclosure_pdf" do
        subject.perform(consent)

        expect(consent).to have_received(:update_or_create_f15080_vita_disclosure_pdf)
      end
    end

    context "disclose_consented_at is not present" do
      before do
        consent.update(disclose_consented_at: nil)
      end

      it "does not call update_or_create_f15080_vita_disclosure_pdf" do
        subject.perform(consent)

        expect(consent).not_to have_received(:update_or_create_f15080_vita_disclosure_pdf)
      end
    end
  end
end

