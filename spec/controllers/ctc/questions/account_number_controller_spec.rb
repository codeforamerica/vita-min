require "rails_helper"

describe Ctc::Questions::AccountNumberController do
  let(:intake) { create :ctc_intake, refund_payment_method: :direct_deposit, bank_account: (create :empty_bank_account) }

  before do
    sign_in intake.client
  end

  describe "#edit" do
    it "redirects to the combined bank account page" do
      get :edit
      expect(response).to redirect_to Ctc::Questions::BankAccountController.to_path_helper
    end
  end

  describe "#update" do
    it "redirects to the combined bank account page" do
      post :update, params: { }
      expect(response).to redirect_to Ctc::Questions::BankAccountController.to_path_helper
    end
  end
end
