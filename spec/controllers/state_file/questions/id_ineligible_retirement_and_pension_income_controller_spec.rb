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

  let!(:spouse_1099r) do
    create :state_file1099_r,
           intake: intake,
           payer_name: "Spouse Payer",
           recipient_name: "Spouse Recipient",
           recipient_ssn: "600000030",
           taxable_amount: 2222
  end

  let!(:state_specific_followup) do
    create :state_file_id1099_r_followup,
           state_file1099_r: primary_1099r,
           civil_service_account_number: "eight"
  end

  before do
    sign_in intake
    allow(Flipper).to receive(:enabled?).and_call_original
    allow(Flipper).to receive(:enabled?).with(:show_retirement_ui).and_return(true)
  end

  describe "#show?" do
    it "returns false" do
      expect(described_class.show?(intake)).to eq false
    end
  end

  describe "#edit" do
    context "when account number starts with 8" do
      it "succeeds" do
        get :edit
        expect(response).to be_successful
      end
    end

    context "when account number does not start with 8" do
      before do
        state_specific_followup.update(civil_service_account_number: "zero_to_four")
      end

      it "redirects to the next path" do
        get :edit
        expect(response).to redirect_to(controller.next_path)
      end
    end
  end

  describe "#file_with_another_service" do
    it "sets clicked_to_file_with_other_service_at timestamp" do
      expect {
        get :file_with_another_service
      }.to change {
        intake.reload.clicked_to_file_with_other_service_at
      }.from(nil).to(be_present)
    end

    it "loads necessary links" do
      expect(controller).to receive(:load_links)
      get :file_with_another_service
    end

    it "renders the file_with_another_service template" do
      get :file_with_another_service
      expect(response).to render_template(:file_with_another_service)
    end
  end

  describe "#continue_filing" do
    before do
      intake.update(clicked_to_file_with_other_service_at: DateTime.now)
    end

    it "sets clicked_to_file_with_other_service_at to nil" do
      expect {
        get :continue_filing
      }.to change {
        intake.reload.clicked_to_file_with_other_service_at
      }.from(be_present).to(nil)
    end

    it "redirects to the next path" do
      get :continue_filing
      expect(response).to redirect_to(controller.next_path)
    end
  end
end


