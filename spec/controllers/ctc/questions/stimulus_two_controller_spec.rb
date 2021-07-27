require "rails_helper"

describe Ctc::Questions::StimulusTwoController do
  let(:intake) { create :ctc_intake, client: client, eip1_amount_received: 0 }
  let(:client) { create :client, tax_returns: [build(:tax_return, year: 2020)] }

  before do
    sign_in intake.client
  end

  describe "#update" do
    it "saves 0 as the amount for stimulus 2 and redirects to the stimulus-received" do
      post :update, params: {
        ctc_stimulus_two_form: {
          eip2_entry_method: 'did_not_receive',
        }
      }

      intake.reload
      expect(intake.eip2_amount_received).to eq 0
      expect(intake).to be_eip2_entry_method_did_not_receive
      expect(response).to redirect_to questions_stimulus_received_path
    end
  end
end
