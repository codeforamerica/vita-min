require "rails_helper"

RSpec.describe StateFile::Questions::NjDisabledExemptionController do
  let(:intake) { create :state_file_nj_intake }
  before do
    sign_in intake
  end

  describe "#edit" do
    render_views
    it 'succeeds' do
      get :edit
      expect(response).to be_successful
    end
  end

  describe "#show" do
    context "when both taxpayer and spouse claimed DirectFile blind" do
      let(:intake) { create :state_file_nj_intake, :married_filing_jointly, :primary_blind, :spouse_blind }
      it "does not show" do
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "when both spouse and taxpayer have not claimed DirectFile blind" do
      let(:intake) { create :state_file_nj_intake, :married_filing_jointly }
      it "shows" do
        expect(described_class.show?(intake)).to eq true
      end
    end

    context "when taxpayer has claimed DirectFile blind but spouse has not" do
      let(:intake) { create :state_file_nj_intake, :married_filing_jointly, :primary_blind }
      it "shows" do
        expect(described_class.show?(intake)).to eq true
      end
    end

    context "when taxpayer is single and they have claimed DirectFile blind" do
      let(:intake) { create :state_file_nj_intake, :primary_blind }
      it "does not show" do
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "when taxpayer is single and they have not claimed DirectFile blind" do
      let(:intake) { create :state_file_nj_intake }
      it "does show" do
        expect(described_class.show?(intake)).to eq true
      end
    end
  end
end