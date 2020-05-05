require "rails_helper"

RSpec.describe Questions::BankDetailsController do
  describe ".show?" do
    let(:refund_method) {nil}
    let(:pay_from_bank) {nil}
    let!(:intake) { create :intake, refund_payment_method: refund_method, balance_pay_from_bank: pay_from_bank }

    context "with an intake that wants their refund by direct deposit" do
      let(:refund_method) { "direct_deposit"}
      let(:pay_from_bank) {"no"}

      it "returns true" do
        expect(Questions::BankDetailsController.show?(intake)).to eq true
      end
    end

    context "with an intake that has not answered how they want their refund" do
      let(:refund_method) { "unfilled"}

      context "when they want to pay by bank account" do
        let(:pay_from_bank) {"yes"}

        it "returns false" do
          expect(Questions::BankDetailsController.show?(intake)).to eq true
        end
      end

      context "when the have not answered whether they want to pay by bank account" do
        let(:pay_from_bank) {"unfilled"}

        it "returns false" do
          expect(Questions::BankDetailsController.show?(intake)).to eq false
        end
      end

      context "when they do not want to pay by bank account" do
        let(:pay_from_bank) {"no"}

        it "returns false" do
          expect(Questions::BankDetailsController.show?(intake)).to eq false
        end
      end
    end

    context "with an intake that wants their refund by mail" do
      let(:refund_method) { "check"}

      context "when they want to pay by bank account" do
        let(:pay_from_bank) {"yes"}

        it "returns false" do
          expect(Questions::BankDetailsController.show?(intake)).to eq true
        end

      end

      context "when the have not answered whether they want to pay by bank account" do
        let(:pay_from_bank) {"unfilled"}

        it "returns false" do
          expect(Questions::BankDetailsController.show?(intake)).to eq false
        end
      end

      context "when they do not want to pay by bank account" do
        let(:pay_from_bank) {"no"}

        it "returns false" do
          expect(Questions::BankDetailsController.show?(intake)).to eq false
        end
      end
    end
  end
end

