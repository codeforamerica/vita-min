require "rails_helper"

describe Ctc::Questions::StimulusPaymentsController do
  let(:intake) { create :ctc_intake, client: client }
  let(:client) { create :client, tax_returns: [build(:tax_return)] }

  before do
    sign_in intake.client
  end

  describe "#edit" do
    before do
      allow(subject).to receive(:track_first_visit)
    end

    it "renders the corresponding template" do
      get :edit
      expect(response).to render_template :edit
    end

    it "tracks the first visit to this page" do
      get :edit
      expect(subject).to have_received(:track_first_visit).with(:stimulus_payments)
    end
  end

  describe "#update" do
    it "persists eip3_entry_method and redirects to the next path" do
      post :update, params: {
        ctc_stimulus_payments_form: {
          eip_received_choice: "this_amount",
        }
      }

      intake.reload
      expect(intake).to be_eip3_entry_method_calculated_amount
      expect(response).to redirect_to questions_stimulus_received_path
    end
  end
end
