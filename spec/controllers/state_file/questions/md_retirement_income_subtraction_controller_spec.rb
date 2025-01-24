require "rails_helper"

describe StateFile::Questions::MdRetirementIncomeSubtractionController do
  let(:intake) { create :state_file_md_intake}

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
    let!(:first_1099r) { create :state_file1099_r, intake: intake, payer_name: "First Payer", recipient_name: "First Recipient", taxable_amount: 1111 }
    let!(:second_1099r) { create :state_file1099_r, intake: intake, payer_name: "Second Payer", recipient_name: "Second Recipient", taxable_amount: 2222 }

    render_views

    it 'succeeds' do
      get :edit
      expect(response).to be_successful
    end

    context "when an index is not provided" do
      it "renders the data for the first 1099R" do
        get :edit
        expect(response.body).to include("First Payer")
        expect(response.body).to include("$1,111")
        expect(response.body).to include("First Recipient")

        expect(response.body).not_to include("Second Payer")
        expect(response.body).not_to include("$2,222")
        expect(response.body).not_to include("Second Recipient")
      end
    end

    context "when an index param is provided" do
      it "renders the data for the 1099R at that index" do
        get :edit, params: { index: 1 }
        expect(response.body).to include("Second Payer")
        expect(response.body).to include("$2,222")
        expect(response.body).to include("Second Recipient")

        expect(response.body).not_to include("First Payer")
        expect(response.body).not_to include("$1,111")
        expect(response.body).not_to include("First Recipient")
      end
    end

    context "when an invalid index param is provided" do
      it "renders a 404" do
        get :edit, params: { index: 2 }
        expect(response).to be_not_found
      end
    end
  end
end