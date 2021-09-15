require "rails_helper"

describe Ctc::Questions::BankAccountController do
  let(:intake) { create :ctc_intake, refund_payment_method: :direct_deposit, bank_account: (create :empty_bank_account) }

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
        expect(intake.bank_account.routing_number).to eq nil
        expect(intake.bank_account.account_number).to eq nil
      end
    end

    context "with a valid answer" do
      let(:params) do
        {
          ctc_bank_account_form: {
            account_type: "savings",
            bank_name: "Bank of Two Melons",
            my_bank_account: "yes",
            routing_number: "123456789",
            routing_number_confirmation: "123456789",
            account_number: "123456789",
            account_number_confirmation: "123456789"
          }
        }
      end

      it "redirects to the next question" do
        post :update, params: params
        expect(response).to redirect_to Ctc::Questions::ConfirmBankAccountController.to_path_helper
      end
    end
  end
end
