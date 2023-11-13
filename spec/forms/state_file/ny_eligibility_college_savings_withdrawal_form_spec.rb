require 'rails_helper'

RSpec.describe StateFile::NyEligibilityCollegeSavingsWithdrawalForm do
  let(:intake) { build :state_file_ny_intake, eligibility_withdrew_529: "unfilled" }

  describe "validations" do
    let(:invalid_params) do
      {
        eligibility_withdrew_529: nil,
      }
    end

    it "requires both params" do
      form = described_class.new(intake, invalid_params)
      form.valid?

      expect(form.errors[:eligibility_withdrew_529]).to include "Can't be blank."
    end
  end

  describe "#save" do
    let(:valid_params) do
      {
        eligibility_withdrew_529: "yes",
      }
    end

    it "saves the answers to the intake" do
      form = described_class.new(intake, valid_params)
      form.save
      intake.reload
      expect(intake.eligibility_withdrew_529_yes?).to eq true
    end
  end
end