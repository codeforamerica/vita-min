require 'rails_helper'

RSpec.describe StateFile::Questions::MdDataTransferOffboardingController do

  let(:intake) { create(:state_file_md_intake) }

  describe ".show?" do
    context "when nra_spouse? true" do
      before do
        allow(intake).to receive(:nra_spouse?).and_return(true)
      end

      it "returns true" do
        expect(described_class.show?(intake)).to eq true
      end
    end

    context "when nra_spouse? false" do
      before do
        allow(intake).to receive(:nra_spouse?).and_return(false)
      end

      it "returns false" do
        expect(described_class.show?(intake)).to eq false
      end
    end
  end
end