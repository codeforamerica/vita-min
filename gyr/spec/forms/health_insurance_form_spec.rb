require "rails_helper"

RSpec.describe HealthInsuranceForm do
  let(:intake) { create :intake }

  let(:no_insurance_params) do
    {
      bought_marketplace_health_insurance: "no",
      bought_employer_health_insurance: "no",
      had_medicaid_medicare: "no",
      had_hsa: "no"
    }
  end

  let(:bought_insurance_params) do
    {
      bought_marketplace_health_insurance: "yes",
      bought_employer_health_insurance: "no",
      had_medicaid_medicare: "no",
      had_hsa: "no"
    }
  end

  describe "#save" do
    it "parses & saves the correct data to the model record when a client did not have insurance" do
      form = HealthInsuranceForm.new(intake, no_insurance_params)
      form.save
      intake.reload

      expect(intake.bought_marketplace_health_insurance).to eq "no"
      expect(intake.bought_employer_health_insurance).to eq "no"
      expect(intake.had_medicaid_medicare).to eq "no"
      expect(intake.had_hsa).to eq "no"
    end

    it "parses & saves the correct data to the model record when a client did have insurance" do
      form = HealthInsuranceForm.new(intake, bought_insurance_params)
      form.save
      intake.reload

      expect(intake.bought_marketplace_health_insurance).to eq "yes"
      expect(intake.bought_employer_health_insurance).to eq "no"
      expect(intake.had_medicaid_medicare).to eq "no"
      expect(intake.had_hsa).to eq "no"
    end
  end
end