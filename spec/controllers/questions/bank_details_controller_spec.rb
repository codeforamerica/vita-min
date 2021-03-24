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

  describe "#update" do
    let(:intake) { create :intake }

    before { sign_in intake.client }

    context "with no values" do
      let(:params) do
        {}
      end

      it "it redirects and fills out account type" do
        put :update, params: params


        expect(response.status).to eq 302
        intake.reload
        expect(intake.bank_account_type).to eq "unspecified"
      end
    end

    context "with all params" do
      let(:params) do
        {
          bank_details_form: {
            bank_name: "Bank of Hamerica",
            bank_routing_number: "1234",
            bank_account_number: "0987",
            bank_account_type: "checking"
          }
        }
      end

      it "saves them to the intake and redirects" do
        put :update, params: params

        expect(response.status).to eq 302
        intake.reload
        expect(intake.bank_name).to eq "Bank of Hamerica"
        expect(intake.bank_routing_number).to eq "1234"
        expect(intake.bank_account_number).to eq "0987"
        expect(intake.bank_account_type).to eq "checking"
      end
    end
  end
end

