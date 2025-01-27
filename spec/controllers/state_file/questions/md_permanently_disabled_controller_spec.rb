require "rails_helper"

RSpec.describe StateFile::Questions::MdPermanentlyDisabledController do
  let(:intake) { create :state_file_md_intake }

  before do
    sign_in intake
    allow(Flipper).to receive(:enabled?).and_call_original
    allow(Flipper).to receive(:enabled?).with(:show_retirement_ui).and_return(true)
  end

  describe "#show?" do
    context "when they have no 1099Rs in their DF XML" do
      it "does not show" do
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "when they have at least one 1099R in their DF XML" do
      let!(:first_1099r) { create :state_file1099_r, intake: intake }

      it "shows" do
        expect(described_class.show?(intake)).to eq true
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