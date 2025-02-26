require "rails_helper"

RSpec.describe StateFile::Questions::MdRetirementIncomeSubtractionController do
  let(:intake) { create :state_file_md_intake }
  let!(:primary_1099r) do
    create :state_file1099_r,
           intake: intake,
           payer_name: "Primary Payer",
           recipient_name: "Primary Recipient",
           recipient_ssn: "400000030",
           taxable_amount: 1111
  end

  let!(:spouse_1099r) do
    create :state_file1099_r,
           intake: intake,
           payer_name: "Spouse Payer",
           recipient_name: "Spouse Recipient",
           recipient_ssn: "600000030",
           taxable_amount: 2222
  end

  before do
    sign_in intake
    allow(Flipper).to receive(:enabled?).and_call_original
    allow(Flipper).to receive(:enabled?).with(:show_retirement_ui).and_return(true)
  end

  describe "#show?" do
    it "shows when all conditions are met" do
      expect(described_class.show?(intake)).to eq true
    end

    context "when the feature flag is disabled" do
      before do
        allow(Flipper).to receive(:enabled?).with(:show_retirement_ui).and_return(false)
      end

      it "does not show" do
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "when they have no eligible 1099Rs" do
      let(:intake) { create :state_file_md_intake }

      before do
        intake.state_file1099_rs.destroy_all
      end

      let!(:non_qualified_1099r) { create :state_file1099_r, intake: intake, taxable_amount: 0 }

      it "does not show" do
        expect(described_class.show?(intake)).to eq false
      end
    end
  end

  describe "#edit" do
    context "with eligible recipients" do
      render_views

      it "succeeds" do
        get :edit
        expect(response).to be_successful
      end

      context "when an index is not provided" do
        it "renders the data for the first eligible 1099R" do
          get :edit
          expect(response.body).to include("Primary Payer")
          expect(response.body).to include("$1,111")
          expect(response.body).to include("Primary Recipient")

          expect(response.body).not_to include("Spouse Payer")
          expect(response.body).not_to include("$2,222")
          expect(response.body).not_to include("Spouse Recipient")
        end
      end

      context "when an index param is provided" do
        it "renders the data for the eligible 1099R at that index" do
          get :edit, params: { index: 1 }
          expect(response.body).to include("Spouse Payer")
          expect(response.body).to include("$2,222")
          expect(response.body).to include("Spouse Recipient")

          expect(response.body).not_to include("Primary Payer")
          expect(response.body).not_to include("$1,111")
          expect(response.body).not_to include("Primary Recipient")
        end
      end

      context "when an invalid index param is provided" do
        it "renders a 404" do
          get :edit, params: { index: 2 }
          expect(response).to be_not_found
        end
      end
    end

    context "with ineligible recipients" do
      let(:intake) { create :state_file_md_intake }
      let!(:non_qualified_1099r) { create :state_file1099_r, intake: intake, taxable_amount: 0 }

      before do
        intake.state_file1099_rs.destroy_all
      end

      it "does not include ineligible 1099Rs" do
        get :edit
        expect(response).to be_not_found
      end
    end
  end
end
