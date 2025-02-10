require "rails_helper"

RSpec.describe StateFile::NjRetirementIncomeSourceForm do
  let(:intake) { create(:state_file_nj_intake) }
  let(:state_file_1099r) { create :state_file1099_r, intake: intake }
  let(:state_specific_followup) { create :state_file_nj1099_r_followup, state_file1099_r: state_file_1099r }
  let(:form) { described_class.new(state_specific_followup, form_params) }

  describe "validations" do
    context "income_source is required" do
      let(:form_params) do
        { income_source: nil }
      end

      it "is invalid" do
        expect(form.valid?).to eq false
        expect(form.errors[:income_source]).to include "Can't be blank."
      end
    end

    context "when income_source is present" do
      let(:form_params) do
        { income_source: :military_pension }
      end

      it "is valid" do
        expect(form.valid?).to eq true
      end
    end
  end

  describe ".save" do
    context "when saving an income source" do
      let(:form_params) do
        { income_source: :military_pension }
      end

      it "saves attributes" do
        form.save
        expect(intake.state_file1099_rs[0].state_specific_followup.income_source).to eq "military_pension"
      end
    end
  end
end
