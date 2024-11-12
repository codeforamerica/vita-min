require "rails_helper"

RSpec.describe StateFile::NjEstimatedTaxPaymentsForm do
  let(:intake) { create :state_file_nj_intake }

  describe "validations" do
    let(:form) { described_class.new(intake, params) }

    it_behaves_like :nj_money_field_concern, field: :estimated_tax_payments, can_be_empty: true do
      let(:form_params) do
        { estimated_tax_payments: money_field_value }
      end
    end
  end

  describe ".save" do
    let(:intake) {
      create :state_file_nj_intake, estimated_tax_payments: 0
    }
    let(:form) { described_class.new(intake, valid_params) }

    context "when saving" do
      let(:valid_params) do
        { estimated_tax_payments: 12345 }
      end

      it "saves attributes" do
        expect(form.valid?).to eq true
        form.save
        expect(intake.estimated_tax_payments).to eq 12345
      end
    end
  end
end
