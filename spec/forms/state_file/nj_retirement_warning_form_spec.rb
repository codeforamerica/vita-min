require 'rails_helper'

RSpec.describe StateFile::NjRetirementWarningForm do
  let(:intake) {
    create :state_file_nj_intake,
    eligibility_retirement_warning_continue: "shown"
  }

  describe "validations" do
    let(:invalid_params) do
      { eligibility_retirement_warning_continue: nil }
    end

    it "requires radio answer" do
      form = described_class.new(intake, invalid_params)
      form.valid?

      expect(form.errors[:eligibility_retirement_warning_continue]).to include "Can't be blank."
    end
  end

  describe "#save" do
    context "when taxpayer selects that they want to continue" do
      let(:valid_params) do
        {
          eligibility_retirement_warning_continue: "yes",
        }
      end
      
      it "saves the yes to the intake" do
        form = described_class.new(intake, valid_params)
        form.save
        intake.reload
        expect(intake.eligibility_retirement_warning_continue_yes?).to eq true
      end
    end

    context "when taxpayer selects that they do NOT want to continue" do
      let(:valid_params) do
        {
          eligibility_retirement_warning_continue: "no",
        }
      end
      
      it "saves the no to the intake" do
        form = described_class.new(intake, valid_params)
        form.save
        intake.reload
        expect(intake.eligibility_retirement_warning_continue_no?).to eq true
      end
    end
  end
end