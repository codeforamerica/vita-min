require "rails_helper"

RSpec.describe RefundPaymentForm do
  let(:intake) { create :intake }

  let(:valid_params) do
    {
      refund_payment_method: "direct_deposit",
      savings_purchase_bond: "yes",
      savings_split_refund: "no"
    }
  end

  describe "validations" do
    context "when all params are valid" do
      it "is valid" do
        form = described_class.new(intake, valid_params)

        expect(form).to be_valid
      end
    end

    context "when refund_payment_method is missing" do
      let(:invalid_params) do
        {
          refund_payment_method: nil,
          savings_purchase_bond: "no",
          savings_split_refund: "no"
        }
      end

      it "is still valid (sets to 'unfilled' in save method)" do
        form = described_class.new(intake, invalid_params)

        expect(form).to be_valid
      end
    end
  end

  describe "#save" do
    context "when refund_payment_method is 'direct_deposit'" do
      let(:form_params) do
        {
          refund_payment_method: "direct_deposit",
          savings_purchase_bond: "yes",
          savings_split_refund: "no"
        }
      end

      it "sets the correct refund payment fields" do
        form = described_class.new(intake, form_params)
        expect(form).to be_valid
        form.save
        intake.reload

        expect(intake.refund_payment_method).to eq "direct_deposit"
        expect(intake.refund_direct_deposit).to eq "yes"
        expect(intake.refund_check_by_mail).to eq "no"
        expect(intake.savings_purchase_bond).to eq "yes"
        expect(intake.savings_split_refund).to eq "no"
        expect(intake.refund_other).to eq "Purchase US Savings Bond"
        expect(intake.refund_other_cb).to eq "yes"
      end
    end

    context "when refund_payment_method is not 'direct_deposit'" do
      let(:form_params) do
        {
          refund_payment_method: "check",
          savings_purchase_bond: "no",
          savings_split_refund: "yes"
        }
      end

      it "sets the correct refund payment fields" do
        form = described_class.new(intake, form_params)
        expect(form).to be_valid
        form.save
        intake.reload

        expect(intake.refund_payment_method).to eq "check"
        expect(intake.refund_direct_deposit).to eq "no"
        expect(intake.refund_check_by_mail).to eq "yes"
        expect(intake.savings_purchase_bond).to eq "no"
        expect(intake.savings_split_refund).to eq "yes"
        expect(intake.refund_other).to eq ""
        expect(intake.refund_other_cb).to eq "no"
      end
    end

    context "when refund_payment_method is missing" do
      let(:form_params) do
        {
          refund_payment_method: nil,
          savings_purchase_bond: "no"
        }
      end

      it "sets refund_payment_method to 'unfilled' and handles other fields" do
        form = described_class.new(intake, form_params)
        expect(form).to be_valid
        form.save
        intake.reload

        expect(intake.refund_payment_method).to eq "unfilled"
        expect(intake.refund_direct_deposit).to eq "no"
        expect(intake.refund_check_by_mail).to eq "yes"
        expect(intake.savings_purchase_bond).to eq "no"
        expect(intake.savings_split_refund).to eq "no"
        expect(intake.refund_other).to eq ""
        expect(intake.refund_other_cb).to eq "no"
      end
    end

    context "when savings_purchase_bond is missing" do
      let(:form_params) do
        {
          refund_payment_method: "direct_deposit",
          savings_purchase_bond: nil,
          savings_split_refund: nil
        }
      end

      it "defaults savings fields to 'no'" do
        form = described_class.new(intake, form_params)
        expect(form).to be_valid
        form.save
        intake.reload

        expect(intake.refund_payment_method).to eq "direct_deposit"
        expect(intake.refund_direct_deposit).to eq "yes"
        expect(intake.refund_check_by_mail).to eq "no"
        expect(intake.savings_purchase_bond).to eq "no"
        expect(intake.savings_split_refund).to eq "no"
        expect(intake.refund_other).to eq ""
        expect(intake.refund_other_cb).to eq "no"
      end
    end
  end
end

