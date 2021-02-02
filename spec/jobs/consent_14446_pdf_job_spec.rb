require 'rails_helper'

RSpec.describe Consent14446PdfJob, type: :job do
  describe "#perform" do
    let(:intake_mock) { double }

    before do
      allow(intake_mock).to receive(:id).and_return 1
      allow(intake_mock).to receive(:create_consent_document)
      allow(Intake).to receive(:find).and_return intake_mock
    end

    it "creates a 14446 consent form document" do
      subject.perform(1)

      expect(intake_mock).to have_received(:create_consent_document)
    end
  end
end

