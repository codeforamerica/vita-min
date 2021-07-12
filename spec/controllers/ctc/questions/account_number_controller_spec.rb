require "rails_helper"

describe Ctc::Questions::AccountNumberController do
  let(:intake) { create :ctc_intake, refund_payment_method: :direct_deposit, bank_account: (create :bank_account) }

  before do
    sign_in intake.client
  end

  describe "#update" do
    context "with no answer" do
      let(:params) do
        {}
      end

      it "re-renders the form with errors" do
        post :update, params: params
        expect(response).to render_template :edit
        expect(assigns(:form).errors).not_to be_blank
        expect(intake.bank_account.account_number).to eq nil
      end
    end

    context "with a valid answer" do
      let(:params) do
        {
            ctc_account_number_form: {
              account_number: "123456789",
              account_number_confirmation: "123456789"
            }
        }
      end

      it "redirects to the next question" do
        post :update, params: params
        expect(response).to redirect_to questions_confirm_bank_account_path
      end
    end
  end
end