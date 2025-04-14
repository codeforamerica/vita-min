require "rails_helper"

RSpec.describe StateFile::Questions::IdPermanentBuildingFundController do
  let(:intake) { create :state_file_id_intake }

  before do
    sign_in intake
  end

  describe ".show?" do
    context "when the client has filing requirement and is not blind" do
      before do
        intake.direct_file_data.total_income_amount = 40000
        intake.direct_file_data.total_itemized_or_standard_deduction_amount = 2112
      end

      it "returns true" do
        expect(described_class.show?(intake)).to eq true
      end
    end

    context "when the client has no filing requirement and is not blind" do
      before do
        intake.direct_file_data.total_income_amount = 2112
        intake.direct_file_data.total_itemized_or_standard_deduction_amount = 40000
      end

      it "returns false" do
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "when the client has filing requirement and is blind" do
      let(:intake) { create :state_file_id_intake, :primary_blind }
      before do
        intake.direct_file_data.total_income_amount = 40000
        intake.direct_file_data.total_itemized_or_standard_deduction_amount = 2112
      end

      it "returns false" do
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "when the client has filing requirement and has a blind spouse" do
      let(:intake) { create :state_file_id_intake, :spouse_blind, :mfj_filer_with_json }
      before do
        intake.direct_file_data.total_income_amount = 40000
        intake.direct_file_data.total_itemized_or_standard_deduction_amount = 2112
      end

      it "returns false" do
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "when the client has no filing requirement and has a blind spouse" do
      let(:intake) { create :state_file_id_intake, :spouse_blind, :mfj_filer_with_json }
      before do
        intake.direct_file_data.total_income_amount = 2112
        intake.direct_file_data.total_itemized_or_standard_deduction_amount = 40000
      end

      it "returns false" do
        expect(described_class.show?(intake)).to eq false
      end
    end
  end

  describe "#update" do
    let(:form_params) do
      {
        state_file_id_permanent_building_fund_form: {
          received_id_public_assistance: "yes",
        }
      }
    end

    it "saves params correctly" do
      post :update, params: form_params
      expect(response).to be_redirect

      intake.reload

      expect(intake).to be_received_id_public_assistance_yes
    end
  end
end
