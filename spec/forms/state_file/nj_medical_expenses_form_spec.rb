require "rails_helper"

RSpec.describe StateFile::NjMedicalExpensesForm do
  let(:intake) { create :state_file_nj_intake }

  describe "validations" do
    let(:form) { described_class.new(intake, params) }

    it_behaves_like :nj_money_field_concern, field: :medical_expenses do
      let(:form_params) do
        { medical_expenses: money_field_value }
      end
    end
  end

  describe ".save" do
    let(:intake) {
      create :state_file_nj_intake, medical_expenses: 0
    }
    let(:form) { described_class.new(intake, valid_params) }

    context "when saving medical expenses" do
      let(:valid_params) do
        { medical_expenses: 12345 }
      end

      it "saves attributes" do
        expect(form.valid?).to eq true
        form.save

        expect(intake.medical_expenses).to eq 12345
      end
    end
  end
end
