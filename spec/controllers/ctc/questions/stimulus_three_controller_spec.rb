require "rails_helper"

describe Ctc::Questions::StimulusThreeController do
  let(:intake) { create :ctc_intake, client: client, eip3_amount_received: nil }
  let(:client) { create :client, tax_returns: [build(:tax_return, year: 2021)] }

  before do
    sign_in intake.client
  end

  describe "#update" do
    context "with no answer" do
      let(:params) do
        {
          ctc_stimulus_three_form: {
            eip3_amount_received: nil
          }
        }
      end

      it "re-renders the form with errors" do
        post :update, params: params
        expect(response).to render_template :edit
        expect(assigns(:form).errors[:eip3_amount_received]).to include "Can't be blank."
        expect(intake.eip3_amount_received).to eq nil
      end
    end

    context "with an invalid answer" do
      let(:params) do
        {
          ctc_stimulus_three_form: {
            eip3_amount_received: "i am not a number"
          }
        }
      end

      it "re-renders the form with errors" do
        post :update, params: params
        expect(response).to render_template :edit
        expect(assigns(:form).errors[:eip3_amount_received]).to include "is not a number"
        expect(intake.eip3_amount_received).to eq nil
      end
    end

    context "with a valid answer" do
      let(:params) do
        {
          ctc_stimulus_three_form: {
            eip3_amount_received: 100
          }
        }
      end

      it "saves eip2_amount_received value" do
        post :update, params: params

        expect(intake.reload.eip3_amount_received).to eq 100
      end
    end
  end
end
