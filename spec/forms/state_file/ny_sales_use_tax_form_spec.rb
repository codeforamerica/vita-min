require "rails_helper"

RSpec.describe StateFile::NySalesUseTaxForm do
  let(:intake) do
    create :state_file_ny_intake,
           untaxed_out_of_state_purchases: "unfilled",
           sales_use_tax_calculation_method: "unfilled",
           sales_use_tax: nil
  end

  describe "#initialize" do
    context "there are values" do
      let(:intake) do
        create :state_file_ny_intake,
               untaxed_out_of_state_purchases: "yes",
               sales_use_tax_calculation_method: "manual",
               sales_use_tax: 350
      end

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
          expect(form.sales_use_tax).to eq nil
        end
      end
    end
  end

  describe "validations" do
    let(:form) { described_class.new(intake, invalid_params) }

    context "invalid params" do
      context "untaxed-out-of-state-purchases is required" do
        let(:invalid_params) do
          {
            untaxed_out_of_state_purchases: nil,
          }
        end

        it "is invalid" do
          expect(form.valid?).to eq false

          expect(form.errors[:untaxed_out_of_state_purchases]).to include "Can't be blank."
        end
      end

      context "sales-use-tax-calculation-method is required if client made untaxed-out-of-state-purchases" do
        let(:invalid_params) do
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
        let(:invalid_params) do
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
        let(:invalid_params) do
          {
            sales_use_tax_calculation_method: "manual",
            sales_use_tax: "NaN",
          }
        end

        it "is invalid" do
          expect(form.valid?).to eq false
          expect(form.errors[:sales_use_tax]).to include "Please enter a dollar amount between 7 and 125."
        end
      end

      context "with a non integer sales-use-tax" do
        let(:invalid_params) do
          {
            sales_use_tax_calculation_method: "manual",
            sales_use_tax: "30.5",
          }
        end

        it "is invalid" do
          expect(form.valid?).to eq false
          expect(form.errors[:sales_use_tax]).to include "Please enter a dollar amount between 7 and 125."
        end
      end

      context "with a value less than 7" do
        let(:invalid_params) do
          {
            sales_use_tax_calculation_method: "manual",
            sales_use_tax: "6",
          }
        end

        it "is invalid" do
          expect(form.valid?).to eq false
          expect(form.errors[:sales_use_tax]).to include "Please enter a dollar amount between 7 and 125."
        end
      end

      context "with a value greater than 125" do
        let(:invalid_params) do
          {
            sales_use_tax_calculation_method: "manual",
            sales_use_tax: "126",
          }
        end

        it "is invalid" do
          expect(form.valid?).to eq false
          expect(form.errors[:sales_use_tax]).to include "Please enter a dollar amount between 7 and 125."
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
          sales_use_tax: 125 }
      end

      it "saves values" do
        expect(form.valid?).to eq true
        form.save

        expect(intake.untaxed_out_of_state_purchases).to eq "yes"
        expect(intake.sales_use_tax_calculation_method).to eq "manual"
        expect(intake.sales_use_tax).to eq 125
      end
    end
  end
end
