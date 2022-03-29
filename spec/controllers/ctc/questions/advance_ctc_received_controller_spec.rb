require "rails_helper"

describe Ctc::Questions::AdvanceCtcReceivedController do
  let(:advance_ctc_amount_received) { 0 }
  let!(:intake) { create :ctc_intake, client: client, advance_ctc_amount_received: advance_ctc_amount_received, advance_ctc_entry_method: "did_not_receive", dependents: [build(:qualifying_child)] }
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
end