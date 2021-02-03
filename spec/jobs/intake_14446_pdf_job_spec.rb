require 'rails_helper'

RSpec.describe Intake14446PdfJob, type: :job do
  describe "#perform" do
    let(:intake) { create(:intake) }

    before do
      allow(intake).to receive(:update_or_create_14446_document)
    end

    it "creates a 14446 PDF with the chosen filename" do
      subject.perform(intake, "filename.pdf")

      expect(intake).to have_received(:update_or_create_14446_document).with("filename.pdf")
    end
  end
end

