require "rails_helper"

RSpec.describe LifeSituationsForm do
  let(:intake) { create :intake }

  let(:no_situations_params) do
    {
      had_disability: "no",
      was_blind: "no",
      primary_us_citizen: "no",
      was_full_time_student: "no",
      no_life_situations_apply: "yes"
    }
  end

  let(:all_situations_params) do
    {
        had_disability: "yes",
        was_blind: "yes",
        primary_us_citizen: "yes",
        was_full_time_student: "yes",
        no_life_situations_apply: "no",
    }
  end

  describe "#save" do
    it "parses & saves the correct data to the model record when situations do not apply" do
      form = LifeSituationsForm.new(intake, no_situations_params)
      form.save
      intake.reload

      expect(intake.had_disability).to eq "no"
      expect(intake.primary_us_citizen).to eq "no"
      expect(intake.was_blind).to eq "no"
      expect(intake.was_full_time_student).to eq "no"
    end

    it "parses & saves the correct data to the model record when situations do apply" do
      form = LifeSituationsForm.new(intake, all_situations_params)
      form.save
      intake.reload

      expect(intake.had_disability).to eq "yes"
      expect(intake.primary_us_citizen).to eq "yes"
      expect(intake.was_blind).to eq "yes"
      expect(intake.was_full_time_student).to eq "yes"
    end
  end

end
