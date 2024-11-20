require 'rails_helper'

RSpec.describe StateFile::NjEligibilityHealthInsuranceForm do
  let(:intake) {
    create :state_file_nj_intake, eligibility_all_members_health_insurance: "unfilled"
  }

  describe "validations" do
    let(:invalid_params) do
      { eligibility_all_members_health_insurance: nil }
    end

    it "requires radio answer" do
      form = described_class.new(intake, invalid_params)
      form.valid?

      expect(form.errors[:eligibility_all_members_health_insurance]).to include "Can't be blank."
    end
  end

  describe "#save" do
    let(:valid_params) do
      { eligibility_all_members_health_insurance: "yes" }
    end

    it "saves the answers to the intake" do
      form = described_class.new(intake, valid_params)
      form.save
      intake.reload
      expect(intake.eligibility_all_members_health_insurance_yes?).to eq true
    end
  end
end