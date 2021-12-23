require 'rails_helper'

RSpec.describe GenerateRequiredConsentPdfJob, type: :job do
  describe "#perform" do
    let(:intake) { create(:intake) }

    before do
      allow(intake).to receive(:update_or_create_required_consent_pdf)
    end

    it "creates a 14446 PDF with the chosen filename" do
      subject.perform(intake)

      expect(intake).to have_received(:update_or_create_required_consent_pdf)
    end
  end
end

