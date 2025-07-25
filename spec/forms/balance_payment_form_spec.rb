require "rails_helper"

RSpec.describe BalancePaymentForm do
  let(:intake) { create :intake }

  describe "validations" do
    it "is invalid without balance_payment_choice" do
      form = described_class.new(intake, {})
      expect(form).not_to be_valid
      expect(form.errors[:balance_payment_choice]).to include(I18n.t('views.questions.balance_payment.error_message'))
    end

    it "is valid with balance_payment_choice" do
      form = described_class.new(intake, { balance_payment_choice: "bank" })
      expect(form).to be_valid
    end
  end

  describe "#save" do
    context "when balance_payment_choice is 'bank'" do
      let(:valid_params) do
        { balance_payment_choice: "bank" }
      end

      it "sets balance_pay_from_bank to 'yes' and payment_in_installments to 'no'" do
        form = described_class.new(intake, valid_params)
        expect(form).to be_valid
        form.save
        intake.reload

        expect(intake.balance_pay_from_bank).to eq "yes"
        expect(intake.payment_in_installments).to eq "no"
      end
    end

    context "when balance_payment_choice is 'mail'" do
      let(:valid_params) do
        { balance_payment_choice: "mail" }
      end

      it "sets balance_pay_from_bank to 'no' and payment_in_installments to 'no'" do
        form = described_class.new(intake, valid_params)
        expect(form).to be_valid
        form.save
        intake.reload

        expect(intake.balance_pay_from_bank).to eq "no"
        expect(intake.payment_in_installments).to eq "no"
      end
    end

    context "when balance_payment_choice is 'installments'" do
      let(:valid_params) do
        { balance_payment_choice: "installments" }
      end

      it "sets balance_pay_from_bank to 'unfilled' and payment_in_installments to 'yes'" do
        form = described_class.new(intake, valid_params)
        expect(form).to be_valid
        form.save
        intake.reload

        expect(intake.balance_pay_from_bank).to eq "unfilled"
        expect(intake.payment_in_installments).to eq "yes"
      end
    end
  end

  describe ".existing_attributes" do
    context "when intake has been answered" do
      context "with bank payment (balance_pay_from_bank: 'yes', payment_in_installments: 'no')" do
        let(:intake) { create :intake, balance_pay_from_bank: "yes", payment_in_installments: "no" }

        it "returns balance_payment_choice as 'bank'" do
          result = described_class.existing_attributes(intake)
          expect(result[:balance_payment_choice]).to eq "bank"
        end
      end
    end
  end
end

