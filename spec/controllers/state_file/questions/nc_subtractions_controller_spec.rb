require "rails_helper"

RSpec.describe StateFile::Questions::NcSubtractionsController do
  let(:intake) { create :state_file_nc_intake }
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
    context "with a positive FAGI" do
      it "shows" do
        allow(intake.direct_file_data).to receive(:fed_agi).and_return(2112)
        expect(described_class.show?(intake)).to eq true
      end
    end

    context "with a FAGI of zero" do
      it "shows does not show" do
        allow(intake.direct_file_data).to receive(:fed_agi).and_return(0)
        expect(described_class.show?(intake)).to eq false
      end
    end
  end
end
