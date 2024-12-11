require "rails_helper"

RSpec.describe StateFile::NjHomeownerPropertyTaxWorksheetForm do
  let(:intake) { create :state_file_nj_intake }

  describe "validations" do
    let(:form) { described_class.new(intake, params) }

    it_behaves_like :nj_money_field_concern, field: :property_tax_paid, can_be_empty: true, must_be_positive: true do
      let(:form_params) do
        { property_tax_paid: money_field_value }
      end
    end

    context "cannot be zero" do
      let(:params) do
        { :property_tax_paid => 0 }
      end

      it "is invalid" do
        expect(form.valid?).to eq false
        expect(form.errors[:property_tax_paid]).to include "must be greater than or equal to 1"
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
