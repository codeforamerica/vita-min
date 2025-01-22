require "rails_helper"

RSpec.describe StateFile::Questions::MdSocialSecurityBenefitsController do
  let(:intake) { create :state_file_md_intake }
  before do
    sign_in intake
  end

  describe ".show?" do
    context "when the client is not mfj" do
      it "returns false" do
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "when the client is mfj" do
      before do
        intake.direct_file_data.filing_status = 2
      end
      context "but does not have fed ssb" do
        it "returns false" do
          expect(described_class.show?(intake)).to eq false
        end
      end

      context "and has fed ssb in the fed return" do
        before do
          intake.direct_file_data.filing_status = 2
          intake.direct_file_data.fed_ssb = "10000"
        end
        it "returns true" do
          expect(described_class.show?(intake)).to eq true
        end
      end
    end
  end


  describe "#edit" do
    render_views
    it "renders the view" do
      get :edit
      expect(response).to be_successful
    end
  end
end


