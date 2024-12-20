require "rails_helper"

RSpec.describe SpouseLifeSituationsForm do
  let(:intake) { create :intake }

  let(:no_situations_params) do
    {
      spouse_had_disability: "no",
      spouse_was_blind: "no",
      spouse_us_citizen: "no",
      spouse_visa: "no",
      spouse_was_full_time_student: "no",
      no_life_situations_apply: "yes",
    }
  end

  let(:all_situations_params) do
    {
        spouse_had_disability: "yes",
        spouse_was_blind: "yes",
        spouse_us_citizen: "yes",
        spouse_visa: "yes",
        spouse_was_full_time_student: "yes",
        no_life_situations_apply: "no",
    }
  end

  describe "#save" do
    it "parses & saves the correct data to the model record when situations do not apply" do
      form = SpouseLifeSituationsForm.new(intake, no_situations_params)
      form.save
      intake.reload

      expect(intake.spouse_had_disability).to eq "no"
      expect(intake.spouse_us_citizen).to eq "no"
      expect(intake.spouse_visa).to eq "no"
      expect(intake.spouse_was_blind).to eq "no"
      expect(intake.spouse_was_full_time_student).to eq "no"
    end

    it "parses & saves the correct data to the model record when situations do apply" do
      form = SpouseLifeSituationsForm.new(intake, all_situations_params)
      form.save
      intake.reload

      expect(intake.spouse_had_disability).to eq "yes"
      expect(intake.spouse_us_citizen).to eq "yes"
      expect(intake.spouse_visa).to eq "yes"
      expect(intake.spouse_was_blind).to eq "yes"
      expect(intake.spouse_was_full_time_student).to eq "yes"
    end
  end

end
