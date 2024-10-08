require "rails_helper"

RSpec.describe StateFile::NjHomeownerPropertyTaxForm do
  let(:intake) { create :state_file_nj_intake }

  describe "validations" do
    let(:form) { described_class.new(intake, invalid_params) }

    context "invalid params" do
      context "all fields are required" do
        let(:invalid_params) do
          { :property_tax_paid => nil }
        end

        it "is invalid" do
          expect(form.valid?).to eq false
          expect(form.errors[:property_tax_paid]).to include "Can't be blank."
        end
      end

      context "must be numeric" do
        let(:invalid_params) do
          { :property_tax_paid => "123A" }
        end

        it "is invalid" do
          expect(form.valid?).to eq false
          expect(form.errors[:property_tax_paid]).to include "Round to the nearest whole number"
        end
      end

      context "must be an integer only" do
        let(:invalid_params) do
          { :property_tax_paid => "123.45" }
        end

        it "is invalid" do
          expect(form.valid?).to eq false
          expect(form.errors[:property_tax_paid]).to include "Round to the nearest whole number"
        end
      end

      context "cannot be negative" do
        let(:invalid_params) do
          { :property_tax_paid => "-123" }
        end

        it "is invalid" do
          expect(form.valid?).to eq false
          expect(form.errors[:property_tax_paid]).to include "must be greater than or equal to 1"
        end
      end

      context "cannot be zero" do
        let(:invalid_params) do
          { :property_tax_paid => "0" }
        end

        it "is invalid" do
          expect(form.valid?).to eq false
          expect(form.errors[:property_tax_paid]).to include "must be greater than or equal to 1"
        end
      end
    end
  end

  describe ".save" do
    let(:intake) {
      create :state_file_nj_intake, property_tax_paid: nil
    }
    let(:form) { described_class.new(intake, valid_params) }

    context "when saving property tax paid" do
      let(:valid_params) do
        { property_tax_paid: 12345 }
      end

      it "saves attributes" do
        expect(form.valid?).to eq true
        form.save

        expect(intake.property_tax_paid).to eq 12345
      end
    end
  end
end
