require 'rails_helper'

RSpec.describe Questions::RefundPaymentController do
  let(:intake) { create :intake }

  before do
    sign_in intake.client
  end

  describe '#update' do
    context 'when user has bank account' do
      let(:params) do
        {refund_payment_form: {refund_direct_deposit: 'yes'}}
      end

      it 'updates other params accordingly' do
        post :update, params: params
        intake.reload
        expect(intake.refund_payment_method).to eq 'direct_deposit'
        expect(intake.refund_check_by_mail).to eq 'no'
      end
    end

    context 'when user does not have bank account' do
      let(:params) do
        {refund_payment_form: {refund_direct_deposit: 'no'}}
      end

      it 'updates other params accordingly' do
        post :update, params: params
        intake.reload
        expect(intake.refund_payment_method).to eq 'check'
        expect(intake.refund_check_by_mail).to eq 'yes'
      end
    end
  end
end
