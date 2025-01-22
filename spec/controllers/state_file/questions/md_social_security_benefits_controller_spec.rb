require "rails_helper"

RSpec.describe StateFile::Questions::MdSocialSecurityBenefitsController do
  let(:intake) { create :state_file_md_intake }
  before do
    sign_in intake
  end

  describe ".show?" do
    context "when the client has fed ssb but is not married filed jointly" do
      let(:intake) { create :state_file_md_intake, :df_data_many_w2s }
      it "returns false" do
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "when the client is mfj" do
      context "but does not have fed ssb" do
        let(:intake) { create :state_file_md_intake, filing_status: "married_filing_jointly" }
        it "returns false" do
          expect(described_class.show?(intake)).to eq false
        end
      end

      context "and has fed ssb in the fed return" do
        let(:intake) { create :state_file_md_intake, :df_data_many_w2s, filing_status: "married_filing_jointly" }
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


