require "rails_helper"

describe Ctc::Portal::BankAccountController do
  let(:bank_account) { create :empty_bank_account }
  let!(:intake) { create :ctc_intake, refund_payment_method: :direct_deposit, bank_account: bank_account }

  before do
    sign_in intake.client
  end

  describe "#update" do
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

    context "when client does not have a pre-existing bank account" do
      let!(:bank_account) { nil }

      it "creates a bank account and some system note" do
        expect do
          expect do
            post :update, params: params
          end.to change(BankAccount, :count).by(1)
        end.to change(SystemNote::CtcPortalUpdate, :count).by(1)
      end
    end

    context "when client has a pre-existing bank account" do
      let!(:bank_account) { create :bank_account }

      it "creates a ctc portal update system note" do
        expect do
          post :update, params: params
        end.to change(SystemNote::CtcPortalUpdate, :count).by(1)
      end
    end
  end
end
