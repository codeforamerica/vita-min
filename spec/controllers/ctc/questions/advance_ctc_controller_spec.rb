require "rails_helper"

describe Ctc::Questions::AdvanceCtcController do
  let!(:intake) { create :ctc_intake, client: client, advance_ctc_amount_received: nil, advance_ctc_entry_method: 'unfilled', dependents: [build(:qualifying_child)] }
  let(:client) { create :client, tax_returns: [build(:tax_return, year: 2021)] }

  before do
    sign_in intake.client
  end

  describe "#edit" do
    it "renders the corresponding template" do
      get :edit
      expect(response).to render_template :edit
    end
  end

  describe "#update" do
    let(:params) do
      {
        ctc_advance_ctc_form: {
          advance_ctc_received_choice: "no_did_not_receive",
        }
      }
    end

    it "persists advance_ctc_entry_method and advance_ctc_amount_received and redirects to the next path" do
      post :update, params: params
      intake.reload
      expect(intake.advance_ctc_entry_method).to eq "did_not_receive"
      expect(intake.advance_ctc_amount_received).to eq 0
      expect(response).to redirect_to Ctc::Questions::AdvanceCtcReceivedController.to_path_helper
    end
  end
end