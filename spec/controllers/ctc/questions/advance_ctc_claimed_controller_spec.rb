require "rails_helper"

describe Ctc::Questions::AdvanceCtcClaimedController do
  let!(:intake) { create :ctc_intake, client: client, advance_ctc_amount_received: 10000, advance_ctc_entry_method: 'manual_entry', dependents: [build(:qualifying_child)] }
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
    context "client selects change amount" do
      let(:params) do
        {
          ctc_advance_ctc_claimed_form: {
            advance_ctc_claimed_choice: "change_amount",
          }
        }
      end

      it "clears advance_ctc_entry_method and advance_ctc_amount_received and redirects to advance ctc amount page" do
        post :update, params: params
        intake.reload
        expect(intake.advance_ctc_entry_method).to eq "unfilled"
        expect(intake.advance_ctc_amount_received).to eq nil
        expect(response).to redirect_to Ctc::Questions::AdvanceCtcAmountController.to_path_helper
      end
    end

    context "client selects add dependents" do
      let(:params) do
        {
          ctc_advance_ctc_claimed_form: {
            advance_ctc_claimed_choice: "add_dependents",
          }
        }
      end

      it "clears advance_ctc_entry_method and advance_ctc_amount_received and redirects to confirm dependents page" do
        post :update, params: params
        intake.reload
        expect(intake.advance_ctc_entry_method).to eq "unfilled"
        expect(intake.advance_ctc_amount_received).to eq nil
        expect(response).to redirect_to Ctc::Questions::ConfirmDependentsController.to_path_helper
      end
    end

    context "client selects don't file" do
      let(:params) do
        {
          ctc_advance_ctc_claimed_form: {
            advance_ctc_claimed_choice: "dont_file",
          }
        }
      end

      it "advance_ctc_entry_method and advance_ctc_amount_received are unchanged and redirects to the not filing page" do
        post :update, params: params
        intake.reload
        expect(intake.advance_ctc_entry_method).to eq "manual_entry"
        expect(intake.advance_ctc_amount_received).to eq 10000
        expect(response).to redirect_to Ctc::Questions::NotFilingController.to_path_helper
      end
    end
  end
end