require 'rails_helper'

RSpec.describe IntakePdfJob, type: :job do
  describe "#perform" do
    let(:intake_mock) { double }

    before do
      allow(intake_mock).to receive(:id).and_return 1
      allow(intake_mock).to receive(:create_intake_document)
      allow(Intake).to receive(:find).and_return intake_mock
    end

    it "creates a 13614-C PDF with the chosen filename" do
      subject.perform(1, "filename.pdf")

      expect(intake_mock).to have_received(:create_intake_document).with("filename.pdf")
    end
  end
end

