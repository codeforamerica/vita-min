require 'rails_helper'

RSpec.describe Intake13614CPdfJob, type: :job do
  describe "#perform" do
    let(:intake) { create(:intake) }

    before do
      allow(intake).to receive(:create_13614c_document)
    end

    it "creates a 13614-C PDF with the chosen filename" do
      subject.perform(intake, "filename.pdf")

      expect(intake).to have_received(:create_13614c_document).with("filename.pdf")
    end
  end
end

