require "rails_helper"

describe Ctc::Questions::StimulusTwoReceivedController do
  let(:intake) { create :ctc_intake, client: client, eip1_amount_received: 0, eip2_amount_received: nil }
  let(:client) { create :client, tax_returns: [build(:tax_return, year: 2021)] }

  before do
    sign_in intake.client
  end

  describe "#update" do
    context "with no answer" do
      let(:params) do
        {
          ctc_stimulus_two_received_form: {
            eip2_amount_received: nil
          }
        }
      end

      it "re-renders the form with errors" do
        post :update, params: params
        expect(response).to render_template :edit
        expect(assigns(:form).errors[:eip2_amount_received]).to include "Can't be blank."
        expect(intake.eip2_amount_received).to eq nil
      end
    end

    context "with an invalid answer" do
      let(:params) do
        {
          ctc_stimulus_two_received_form: {
            eip2_amount_received: "i am not a number"
          }
        }
      end

      it "re-renders the form with errors" do
        post :update, params: params
        expect(response).to render_template :edit
        expect(assigns(:form).errors[:eip2_amount_received]).to include "is not a number"
        expect(intake.eip2_amount_received).to eq nil
      end
    end

    context "with a valid answer" do
      let(:params) do
        {
          ctc_stimulus_two_received_form: {
            eip2_amount_received: 100
          }
        }
      end

      it "saves eip2_amount_received value" do
        post :update, params: params

        expect(intake.reload.eip2_amount_received).to eq 100
      end

      context "when all stimulus money has been paid to the client" do
        before do
          allow_any_instance_of(TaxReturn).to receive(:outstanding_recovery_rebate_credit).and_return 0
        end

        it "redirects to the stimulus received path" do
          post :update, params: params
          expect(response).to redirect_to questions_stimulus_received_path
        end
      end

      context "when the client has unclaimed stimulus money" do
        before do
          allow_any_instance_of(TaxReturn).to receive(:outstanding_recovery_rebate_credit).and_return 1000
        end

        it "redirects to the stimulus received path" do
          post :update, params: params
          expect(response).to redirect_to questions_stimulus_owed_path
        end
      end
    end
  end
end
