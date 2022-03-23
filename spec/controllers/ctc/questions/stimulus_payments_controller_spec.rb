require "rails_helper"

describe Ctc::Questions::StimulusPaymentsController do
  let(:intake) { create :ctc_intake, client: client }
  let(:client) { create :client, tax_returns: [build(:tax_return, year: 2021)] }

  before do
    sign_in intake.client
  end

  describe "#update" do
    it "persists eip1_entry_method and eip2_entry_method and redirects to the next path" do
      post :update, params: {
        ctc_stimulus_payments_form: {
          eip_received_choice: "yes_received",
        }
      }

      intake.reload
      expect(intake).to be_eip1_entry_method_calculated_amount
      expect(intake).to be_eip2_entry_method_calculated_amount
      # TODO: correct redirect to next path for new RRC flow
    end
  end
end
