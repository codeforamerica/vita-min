require "rails_helper"

RSpec.describe SpouseLifeSituationsForm do
  let(:intake) { create :intake }

  let(:no_situations_params) do
    {
      spouse_had_disability: "no",
      spouse_was_blind: "no",
      spouse_was_on_visa: "no",
      spouse_was_full_time_student: "no"
    }
  end

  let(:all_situations_params) do
    {
        spouse_had_disability: "yes",
        spouse_was_blind: "yes",
        spouse_was_on_visa: "yes",
        spouse_was_full_time_student: "yes"
    }
  end

  describe "#save" do
    it "parses & saves the correct data to the model record when situations do not apply" do
      form = SpouseLifeSituationsForm.new(intake, no_situations_params)
      form.save
      intake.reload

      expect(intake.spouse_had_disability).to eq "no"
      expect(intake.spouse_was_on_visa).to eq "no"
      expect(intake.spouse_was_blind).to eq "no"
      expect(intake.spouse_was_full_time_student).to eq "no"
    end

    it "parses & saves the correct data to the model record when situations do apply" do
      form = SpouseLifeSituationsForm.new(intake, all_situations_params)
      form.save
      intake.reload

      expect(intake.spouse_had_disability).to eq "yes"
      expect(intake.spouse_was_on_visa).to eq "yes"
      expect(intake.spouse_was_blind).to eq "yes"
      expect(intake.spouse_was_full_time_student).to eq "yes"
    end
  end

end