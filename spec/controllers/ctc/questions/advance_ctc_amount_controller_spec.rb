require "rails_helper"

describe Ctc::Questions::AdvanceCtcAmountController do
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
    context "with valid value" do
      let(:params) do
        {
          ctc_advance_ctc_amount_form: {
            advance_ctc_amount_received: 1000,
          }
        }
      end

      it "persists advance_ctc_entry_method and advance_ctc_amount_received and redirects to the next path" do
        post :update, params: params
        intake.reload
        expect(intake.advance_ctc_entry_method).to eq "manual_entry"
        expect(intake.advance_ctc_amount_received).to eq 1000
        expect(response).to redirect_to Ctc::Questions::AdvanceCtcReceivedController.to_path_helper
      end
    end

    context "with an invalid value" do
      let(:params) do
        {
          ctc_advance_ctc_amount_form: {
            advance_ctc_amount_received: "hello",
          }
        }
      end

      it "re-renders the form with errors" do
        post :update, params: params
        expect(response).to render_template :edit
        expect(assigns(:form).errors[:advance_ctc_amount_received]).to include "is not a number"
        expect(intake.advance_ctc_amount_received).to eq nil
      end
    end

    context "with no value" do
      let(:params) do
        {
          ctc_advance_ctc_amount_form: {
            advance_ctc_amount_received: nil,
          }
        }
      end

      it "re-renders the form with errors" do
        post :update, params: params
        expect(response).to render_template :edit
        expect(assigns(:form).errors[:advance_ctc_amount_received]).to include "Can't be blank."
        expect(intake.advance_ctc_amount_received).to eq nil
      end
    end
  end
end