require 'rails_helper'

RSpec.describe GenerateF13614cPdfJob, type: :job do
  describe "#perform" do
    let(:intake_mock) { double }

    before do
      allow(intake_mock).to receive(:id).and_return 1
      allow(intake_mock).to receive(:update_or_create_13614c_document)
      allow(Intake).to receive(:find).and_return intake_mock
    end

    it "creates a 13614-C PDF with the chosen filename" do
      subject.perform(1, "filename.pdf")

      expect(intake_mock).to have_received(:update_or_create_13614c_document).with("filename.pdf")
    end
  end
end

