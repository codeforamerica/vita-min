require "rails_helper"

describe Ctc::Questions::StimulusTwoController do
  let(:intake) { create :ctc_intake, client: client, eip1_amount_received: 0 }
  let(:client) { create :client, tax_returns: [build(:tax_return, year: 2021)] }

  before do
    sign_in intake.client
  end

  describe "#update" do
    before do
      # now that we aren't calculating EIP for 2021, this breaks unless we change the tax year to 2020
      # Will be removed when we update the stimulus flow
      allow_any_instance_of(TaxReturn).to receive(:year).and_return 2020
    end
    it "saves 0 as the amount for stimulus 2 and redirects to stimulus-owed" do
      post :update, params: {
        ctc_stimulus_two_form: {
          eip2_entry_method: 'did_not_receive',
        }
      }

      intake.reload
      expect(intake.eip2_amount_received).to eq 0
      expect(intake).to be_eip2_entry_method_did_not_receive
      expect(response).to redirect_to questions_stimulus_owed_path
    end
  end
end
