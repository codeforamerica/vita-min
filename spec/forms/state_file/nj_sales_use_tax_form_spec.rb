require "rails_helper"

RSpec.describe StateFile::NjSalesUseTaxForm do

  let(:intake_untaxed_out_of_state_purchases) { "unfilled" }
  let(:intake_sales_use_tax_calculation_method) { "unfilled" }
  let(:intake_sales_use_tax) { nil }
  let(:intake) do
    create :state_file_nj_intake,
           untaxed_out_of_state_purchases: intake_untaxed_out_of_state_purchases,
           sales_use_tax_calculation_method: intake_sales_use_tax_calculation_method,
           sales_use_tax: intake_sales_use_tax
  end

  describe "#initialize" do
    context "there are values" do
      let(:intake_untaxed_out_of_state_purchases) { "yes" }
      let(:intake_sales_use_tax_calculation_method) { "manual" }
      let(:intake_sales_use_tax) { 1800 }

      let(:params) do
        { untaxed_out_of_state_purchases: untaxed_out_of_state_purchases,
          sales_use_tax_calculation_method: sales_use_tax_calculation_method,
          sales_use_tax: intake.sales_use_tax }
      end

      context "if untaxed_out_of_state_purchases changes to no" do
        let(:untaxed_out_of_state_purchases) { "no" }
        let(:sales_use_tax_calculation_method) { intake.sales_use_tax_calculation_method }

        it "clears the calc method and sales use tax" do
          form = described_class.new(intake, params)
          expect(form.untaxed_out_of_state_purchases).to eq "no"
          expect(form.sales_use_tax_calculation_method).to eq "unfilled"
          expect(form.sales_use_tax).to eq nil
        end
      end

      context "if calc method changes to automated" do
        let(:untaxed_out_of_state_purchases) { "yes" }
        let(:sales_use_tax_calculation_method) { "automated" }

        it "clears the sales use tax" do
          form = described_class.new(intake, params)
          expect(form.untaxed_out_of_state_purchases).to eq "yes"
          expect(form.sales_use_tax_calculation_method).to eq "automated"
          expect(form.sales_use_tax).to eq intake.calculate_sales_use_tax
        end
      end
    end
  end

  describe "validations" do
    let(:form) { described_class.new(intake, params) }

    context "invalid params" do
      context "untaxed-out-of-state-purchases is required" do
        let(:params) do
          { untaxed_out_of_state_purchases: nil }
        end

        it "is invalid" do
          expect(form.valid?).to eq false
          expect(form.errors[:untaxed_out_of_state_purchases]).to include "Can't be blank."
        end
      end

      context "sales-use-tax-calculation-method is required if client made untaxed-out-of-state-purchases" do
        let(:params) do
          {
            untaxed_out_of_state_purchases: "yes",
            sales_use_tax_calculation_method: nil
          }
        end

        it "is invalid" do
          expect(form.valid?).to eq false
          expect(form.errors[:sales_use_tax_calculation_method]).to include "Can't be blank."
        end
      end

      context "if client made untaxed-out-of-state-purchases and will calculate sales use tax manually" do
        let(:params) do
          {
            untaxed_out_of_state_purchases: "yes",
            sales_use_tax_calculation_method: "manual",
            sales_use_tax: ""
          }
        end

        it "is invalid" do
          expect(form.valid?).to eq false
          expect(form.errors[:sales_use_tax]).to include "Can't be blank."
        end
      end

      context "with a non numeric sales-use-tax" do
        let(:params) do
          {
            untaxed_out_of_state_purchases: "yes",
            sales_use_tax_calculation_method: "manual",
            sales_use_tax: "NaN",
          }
        end

        it "is invalid" do
          expect(form.valid?).to eq false
          expect(form.errors[:sales_use_tax]).to include "Please enter numbers only."
        end
      end

      context "with a value less than 0" do
        let(:params) do
          {
            untaxed_out_of_state_purchases: "yes",
            sales_use_tax_calculation_method: "manual",
            sales_use_tax: "-1",
          }
        end

        it "is invalid" do
          expect(form.valid?).to eq false
          expect(form.errors[:sales_use_tax]).to include "Please enter numbers only."
        end
      end
    end

    context "valid params" do

      context "with a non-integer sales-use-tax" do
        let(:params) do
          {
            untaxed_out_of_state_purchases: "yes",
            sales_use_tax_calculation_method: "manual",
            sales_use_tax: "30.5",
          }
        end

        it "is valid" do
          expect(form.valid?).to eq true
        end
      end

      context "with an integer sales-use-tax" do
        let(:params) do
          {
            untaxed_out_of_state_purchases: "yes",
            sales_use_tax_calculation_method: "manual",
            sales_use_tax: "30",
          }
        end

        it "is valid" do
          expect(form.valid?).to eq true
        end
      end

    end
  end

  describe "#save" do
    let(:form) { described_class.new(intake, valid_params) }

    context "they have made untaxed-out-of-state-purchases and will calculate manually" do
      let(:valid_params) do
        { untaxed_out_of_state_purchases: "yes",
          sales_use_tax_calculation_method: "manual",
          sales_use_tax: 1699 }
      end

      it "saves values" do
        expect(form.valid?).to eq true
        form.save

        expect(intake.untaxed_out_of_state_purchases).to eq "yes"
        expect(intake.sales_use_tax_calculation_method).to eq "manual"
        expect(intake.sales_use_tax).to eq 1699
      end
    end
  end
end
