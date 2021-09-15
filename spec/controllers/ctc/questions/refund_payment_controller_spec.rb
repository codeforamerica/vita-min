require "rails_helper"

describe Ctc::Questions::RefundPaymentController do
  let(:intake) { create :intake }

  before do
    sign_in intake.client
  end

  describe "#update" do
    context "with no answer" do
      let(:params) do
        {}
      end

      it "leaves the attribute unfilled and adds errors to the form" do
        post :update, params: params
        expect(response).to render_template :edit
        expect(assigns(:form).errors).not_to be_blank
        expect(intake.refund_payment_method).to eq "unfilled"
      end
    end

    context "with a valid answer" do
      context "direct_deposit" do
        let(:params) do
          {
            ctc_refund_payment_form: {
              refund_payment_method: "direct_deposit"
            }
          }
        end

        it "redirects to the next question" do
          post :update, params: params
          expect(response).to redirect_to Ctc::Questions::BankAccountController.to_path_helper
        end
      end

      context "check" do
        let(:params) do
          {
              ctc_refund_payment_form: {
                  refund_payment_method: "check"
              }
          }
        end

        it "redirects to the next question" do
          post :update, params: params
          expect(response).to redirect_to questions_mailing_address_path
        end
      end
    end
  end
end
