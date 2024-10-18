require 'rails_helper'

RSpec.describe StateFile::Questions::MdSpouseStateIdController do
  describe ".show?" do
    context "with an intake that reports married filed jointly" do
      let!(:intake) { create :state_file_nc_intake, filing_status: :married_filing_jointly}

      it "returns true" do
        expect(described_class.show?(intake)).to eq true
      end
    end

    context "with an intake that does not reports married filed jointly" do
      let!(:intake) { create :state_file_nc_intake, filing_status: :single}

      it "returns false" do
        expect(described_class.show?(intake)).to eq false
      end
    end
  end
end
