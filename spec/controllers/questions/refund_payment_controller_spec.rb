require "rails_helper"

RSpec.describe Questions::RefundPaymentController do
  let(:intake) { create :intake }

  before do
    allow(subject).to receive(:current_intake).and_return(intake)
  end

  describe "#update" do
    context "with no answer" do
      let(:params) do
        {}
      end

      it "leaves the attribute unfilled" do
        post :update, params: params

        intake.reload
        expect(intake.refund_payment_method).to eq "unfilled"
      end
    end
  end
end
