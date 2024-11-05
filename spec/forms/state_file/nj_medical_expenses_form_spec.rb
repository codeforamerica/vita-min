require "rails_helper"

RSpec.describe StateFile::NjMedicalExpensesForm do
  let(:intake) { create :state_file_nj_intake }

  describe "validations" do
    let(:form) { described_class.new(intake, params) }

    context "invalid params" do
      context "must be numeric" do
        let(:params) do
          { medical_expenses: "awefwaefw" }
        end

        it "is invalid" do
          expect(form.valid?).to eq false
          expect(form.errors[:medical_expenses]).to include "Please enter numbers only."
        end
      end

      context "cannot be negative" do
        let(:params) do
          { medical_expenses: "-123" }
        end

        it "is invalid" do
          expect(form.valid?).to eq false
          expect(form.errors[:medical_expenses]).to include "must be greater than or equal to 0"
        end
      end
    end

    context "valid params" do
      context "can be a decimal" do
        let(:params) do
          { medical_expenses: 123.45 }
        end

        it "is valid" do
          expect(form.valid?).to eq true
        end
      end

      context "can be an integer" do
        let(:params) do
          { medical_expenses: 123 }
        end

        it "is valid" do
          expect(form.valid?).to eq true
        end
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
