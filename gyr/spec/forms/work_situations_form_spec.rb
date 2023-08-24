require "rails_helper"

RSpec.describe WorkSituationsForm do
  let(:intake) { create :intake }

  let(:no_situations_params) do
    {
      had_wages: "no",
      had_self_employment_income: "no",
      had_tips: "no",
      had_unemployment_income: "no"
    }
  end

  let(:all_situations_params) do
    {
        had_wages: "yes",
        had_self_employment_income: "yes",
        had_tips: "yes",
        had_unemployment_income: "yes"
    }
  end

  describe "#save" do
    it "parses & saves the correct data to the model record when situations do not apply" do
      form = WorkSituationsForm.new(intake, no_situations_params)
      form.save
      intake.reload

      expect(intake.had_wages).to eq "no"
      expect(intake.had_self_employment_income).to eq "no"
      expect(intake.had_tips).to eq "no"
      expect(intake.had_unemployment_income).to eq "no"
    end

    it "parses & saves the correct data to the model record when situations do apply" do
      form = WorkSituationsForm.new(intake, all_situations_params)
      form.save
      intake.reload

      expect(intake.had_wages).to eq "yes"
      expect(intake.had_self_employment_income).to eq "yes"
      expect(intake.had_tips).to eq "yes"
      expect(intake.had_unemployment_income).to eq "yes"
    end
  end
end