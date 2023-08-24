require "rails_helper"

describe Ctc::Questions::ConfirmBankAccountController do
  let(:intake) { create(:ctc_intake) }

  describe "#edit" do
    before do
      sign_in intake.client
    end

    context 'when bank_account is present' do
      before do
        intake.update(bank_account: build(:bank_account))
      end

      it 'redirects to the bank account creation page' do
        get :edit
        expect(response).to be_ok
      end
    end

    context 'when bank_account is not present' do
      it 'redirects to the bank account creation page' do
        get :edit
        expect(response).to redirect_to Ctc::Questions::BankAccountController.to_path_helper
      end
    end
  end
end
