require "rails_helper"

describe Ctc::Questions::StimulusPaymentsController do
  let(:intake) { create :ctc_intake, client: client }
  let(:client) { create :client, tax_returns: [build(:tax_return, year: 2020)] }

  before do
    sign_in intake.client
  end

  describe "#update" do
    it "persists eip1_entry_method and eip2_entry_method and redirects to the next path" do
      post :update, params: {
        ctc_stimulus_payments_form: {
          eip1_entry_method: "calculated_amount",
          eip2_entry_method: "calculated_amount"
        }
      }

      intake.reload
      expect(intake).to be_eip1_entry_method_calculated_amount
      expect(intake).to be_eip2_entry_method_calculated_amount
      expect(response).to redirect_to questions_stimulus_received_path
    end
  end
end
