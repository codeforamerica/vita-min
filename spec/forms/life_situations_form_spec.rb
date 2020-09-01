require "rails_helper"

RSpec.describe LifeSituationsForm do
  let(:intake) { create :intake }

  let(:no_situations_params) do
    {
      had_disability: "no",
      was_blind: "no",
      was_on_visa: "no",
      was_full_time_student: "no"
    }
  end

  let(:all_situations_params) do
    {
        had_disability: "yes",
        was_blind: "yes",
        was_on_visa: "yes",
        was_full_time_student: "yes"
    }
  end

  describe "#save" do
    it "parses & saves the correct data to the model record when situations do not apply" do
      form = LifeSituationsForm.new(intake, no_situations_params)
      form.save
      intake.reload

      expect(intake.had_disability).to eq "no"
      expect(intake.was_on_visa).to eq "no"
      expect(intake.was_blind).to eq "no"
      expect(intake.was_full_time_student).to eq "no"
    end

    it "parses & saves the correct data to the model record when situations do apply" do
      form = LifeSituationsForm.new(intake, all_situations_params)
      form.save
      intake.reload

      expect(intake.had_disability).to eq "yes"
      expect(intake.was_on_visa).to eq "yes"
      expect(intake.was_blind).to eq "yes"
      expect(intake.was_full_time_student).to eq "yes"
    end
  end

end