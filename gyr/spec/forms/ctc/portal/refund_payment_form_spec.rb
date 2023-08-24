require "rails_helper"

describe Ctc::Portal::RefundPaymentForm do
  let(:intake) { create :ctc_intake, refund_payment_method: refund_payment_method }
  let(:refund_payment_method) { "unfilled" }
  let!(:bank_account) { create :bank_account, intake: intake }

  context "validations" do
    it "requires refund_payment_method" do
      form = described_class.new(intake, {})
      expect(form).not_to be_valid
    end
  end

  describe "#save" do
    it "persists the refund payment value to the intake" do
      expect {
        described_class.new(intake, { refund_payment_method: "check" }).save
      }.to change(intake, :refund_payment_method).from("unfilled").to("check")
    end

    context "when the refund_payment_method is changed from direct deposit to mail-in check" do
      let(:refund_payment_method) { "direct_deposit" }

      it "deletes the bank account associated to the client" do
        described_class.new(intake, { refund_payment_method: "check" }).save

        expect(intake.reload.bank_account).to eq nil
      end
    end

    context "when refund_payment_method was direct deposit and direct deposit is selected" do
      let(:refund_payment_method) { "direct_deposit" }

      it "does not delete the bank account" do
        expect do
          described_class.new(intake, { refund_payment_method: "direct_deposit" }).save
        end.to change(BankAccount, :count).by(0)
      end
    end
  end
end