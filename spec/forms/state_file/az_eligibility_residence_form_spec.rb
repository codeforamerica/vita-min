require 'rails_helper'

RSpec.describe StateFile::AzEligibilityResidenceForm do
  let(:intake) {
    create :state_file_az_intake,
           eligibility_lived_in_state: "unfilled",
           eligibility_married_filing_separately: "unfilled"
  }

  describe "validations" do
    let(:invalid_params) do
      {
        eligibility_lived_in_state: nil,
        eligibility_married_filing_separately: nil,
      }
    end

    it "requires both params" do
      form = described_class.new(intake, invalid_params)
      form.valid?

      expect(form.errors[:eligibility_lived_in_state]).to include "Can't be blank."
      expect(form.errors[:eligibility_married_filing_separately]).to include "Can't be blank."
    end
  end

  describe "#save" do
    let(:valid_params) do
      {
        eligibility_lived_in_state: "yes",
        eligibility_married_filing_separately: "no",
      }
    end

    it "saves the answers to the intake" do
      form = described_class.new(intake, valid_params)
      form.save
      intake.reload
      expect(intake.eligibility_lived_in_state_yes?).to eq true
      expect(intake.eligibility_married_filing_separately_no?).to eq true
    end
  end
end