require "rails_helper"

RSpec.describe StateFile::Questions::NjEitcQualifyingChildController do
  let(:intake) { create :state_file_nj_intake }
  before do
    sign_in intake
  end

  describe "#show?" do
    context "when ineligible for flat eitc" do
      let(:intake) { create :state_file_nj_intake }
      it "does not show" do
        allow(Efile::Nj::NjFlatEitcEligibility).to receive(:possibly_eligible?).with(intake).and_return(false)
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "when possibly eligible for flat eitc" do
      let(:intake) { create :state_file_nj_intake }
      it "shows" do
        allow(Efile::Nj::NjFlatEitcEligibility).to receive(:possibly_eligible?).with(intake).and_return(true)
        expect(described_class.show?(intake)).to eq true
      end
    end
  end

  describe "#edit" do
    render_views
    it 'succeeds' do
      get :edit
      expect(response).to be_successful
    end
  end
end
