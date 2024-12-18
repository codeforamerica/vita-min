require "rails_helper"

RSpec.describe StateFile::IdSalesUseTaxForm do
  let(:intake_has_unpaid_sales_use_tax) { "no" }
  let(:total_purchase_amount) { nil }
  let(:intake) do
    create :state_file_id_intake,
           has_unpaid_sales_use_tax: intake_has_unpaid_sales_use_tax,
           total_purchase_amount: total_purchase_amount
  end

  describe "validations" do
    let(:form) { described_class.new(intake, params) }

    context "invalid params" do
      context "has_unpaid_sales_use_tax is required" do
        let(:params) do
          {
            has_unpaid_sales_use_tax: nil,
          }
        end

        it "is invalid" do
          expect(form.valid?).to eq false

          expect(form.errors[:has_unpaid_sales_use_tax]).to include "Can't be blank."
        end
      end

      context "sales_use_tax is required if client has_unpaid_sales_use_tax" do
        let(:params) do
          {
            has_unpaid_sales_use_tax: "yes",
            total_purchase_amount: nil
          }
        end

        it "is invalid" do
          expect(form.valid?).to eq false

          expect(form.errors[:total_purchase_amount]).to include "Can't be blank."
        end
      end

      context "with a non numeric sales-use-tax" do
        let(:params) do
          {
            has_unpaid_sales_use_tax: "yes",
            total_purchase_amount: "NaN",
          }
        end

        it "is valid" do
          expect(form.valid?).to eq false
          expect(form.errors[:total_purchase_amount]).to include "Please enter numbers only."
        end
      end

      context "with a value less than 0" do
        let(:params) do
          {
            has_unpaid_sales_use_tax: "yes",
            total_purchase_amount: "-1",
          }
        end

        it "is invalid" do
          expect(form.valid?).to eq false
          expect(form.errors[:total_purchase_amount]).to include "Please enter numbers only."
        end
      end
    end

    context "valid params" do

      context "with a non integer sales-use-tax" do
        let(:params) do
          {
            has_unpaid_sales_use_tax: "yes",
            total_purchase_amount: "30.5",
          }
        end

        it "is invalid" do
          expect(form.valid?).to eq true
        end
      end

    end
  end

  describe "#save" do
    let(:form) { described_class.new(intake, valid_params) }

    context "has unpaid sales use tax" do
      let(:valid_params) do
        { has_unpaid_sales_use_tax: "yes",
          total_purchase_amount: 1699.51 }
      end

      it "saves values" do
        expect(form.valid?).to eq true
        form.save

        expect(intake.has_unpaid_sales_use_tax).to eq "yes"
        expect(intake.total_purchase_amount).to eq 1699.51
      end
    end

    context "no longer has unpaid sales use tax (switched after selecting 'yes' and inputting value)" do
      let(:valid_params) do
        { has_unpaid_sales_use_tax: "no",
          total_purchase_amount: 1699.51 }
      end

      it "saves values" do
        expect(form.valid?).to eq true
        form.save

        expect(intake.has_unpaid_sales_use_tax).to eq "no"
        expect(intake.total_purchase_amount).to eq nil
      end
    end
  end
end
