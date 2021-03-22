require 'rails_helper'

RSpec.describe OptionalConsentPdfJob, type: :job do
  describe "#perform" do
    let(:consent) { create(:consent, client: create(:client)) }

    before do
      allow(consent).to receive(:update_or_create_optional_consent_pdf)
    end

    it "creates a optional consent PDF" do
      subject.perform(consent)

      expect(consent).to have_received(:update_or_create_optional_consent_pdf)
    end
  end
end

