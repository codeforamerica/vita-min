require "rails_helper"

RSpec.describe StateFile::Questions::IdIneligibleRetirementAndPensionIncomeController do
  let(:intake) { create :state_file_id_intake, :mfj_filer_with_json, primary_disabled: "yes", spouse_disabled: "yes" }
  let!(:primary_1099r) do
    create :state_file1099_r,
           intake: intake,
           payer_name: "Primary Payer",
           recipient_name: "Primary Recipient",
           recipient_ssn: "400000030",
           taxable_amount: 1111
  end

  let!(:second_primary_1099r) do
    create :state_file1099_r,
           intake: intake,
           payer_name: "Primary Payer",
           recipient_name: "Primary Recipient",
           recipient_ssn: "400000030",
           taxable_amount: 1111
  end

  let!(:state_specific_followup) do
    create :state_file_id1099_r_followup,
           state_file1099_r: primary_1099r,
           civil_service_account_number: "eight"
  end

  let!(:second_state_specific_followup) do
    create :state_file_id1099_r_followup,
           state_file1099_r: second_primary_1099r,
           civil_service_account_number: "seven_or_nine"
  end

  before do
    sign_in intake
    allow(Flipper).to receive(:enabled?).and_call_original
    allow(Flipper).to receive(:enabled?).with(:show_retirement_ui).and_return(true)
  end

  describe "#show?" do
    it "returns true if 1099-R followup can not be deducted" do
      expect(described_class.show?(intake, item_index: 0)).to eq true
    end

    it "returns false if 1099-R followup can be deducted" do
      expect(described_class.show?(intake, item_index: 1)).to eq false
    end
  end

  describe "#edit" do
    context "when civil servant employee account number starts with 8" do
      it "succeeds" do
        get :edit
        expect(response).to be_successful
      end
    end

    context "when user clicked through to file with another service, then clicked back to continue with this service" do
      before do
        intake.update(clicked_to_file_with_other_service_at: nil)
      end

      it "sets clicked_to_file_with_other_service_at to nil" do
        get :edit
        expect(intake.reload.clicked_to_file_with_other_service_at).to eq nil
      end
    end
  end

  describe "#file_with_another_service" do
    it "sets clicked_to_file_with_other_service_at timestamp" do
      get :file_with_another_service
      expect(intake.reload.clicked_to_file_with_other_service_at).to be_present
    end
  end

end