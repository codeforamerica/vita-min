require "rails_helper"

RSpec.describe StateFile::NjTenantPropertyTaxWorksheetForm do
  let(:intake) { create :state_file_nj_intake }

  describe "validations" do
    let(:form) { described_class.new(intake, params) }

    it_behaves_like :nj_money_field_concern, field: :rent_paid, can_be_empty: true, must_be_positive: true do
      let(:form_params) do
        { rent_paid: money_field_value }
      end
    end
  end

  describe ".save" do
    let(:intake) {
      create :state_file_nj_intake, rent_paid: nil
    }
    let(:form) { described_class.new(intake, valid_params) }

    context "when saving property tax paid" do
      let(:valid_params) do
        { rent_paid: 12345 }
      end

      it "saves attributes" do
        expect(form.valid?).to eq true
        form.save

        expect(intake.rent_paid).to eq 12345
      end
    end
  end
end
