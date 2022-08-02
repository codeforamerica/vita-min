require "rails_helper"

describe Ctc::EitcQualifiersForm do
  let(:intake) { create :ctc_intake }

  describe "validations" do
    it "is invalid if no boxes are checked" do
      form = described_class.new(intake, {})
      expect(form.valid?).to eq false
    end
  end

  describe "#save" do
    let(:no_qualifiers_params) do
      {
        former_foster_youth: "no",
        homeless_youth: "no",
        not_full_time_student: "no",
        full_time_student_less_than_four_months: "no"
      }
    end

    let(:all_qualifiers_params) do
      {
        former_foster_youth: "yes",
        homeless_youth: "yes",
        not_full_time_student: "yes",
        full_time_student_less_than_four_months: "yes"
      }
    end

    it "parses & saves the correct data to the model record when situations do not apply" do
      form = described_class.new(intake, no_qualifiers_params)
      form.save
      intake.reload

      expect(intake.former_foster_youth).to eq "no"
      expect(intake.homeless_youth).to eq "no"
      expect(intake.not_full_time_student).to eq "no"
      expect(intake.full_time_student_less_than_four_months).to eq "no"
    end

    it "parses & saves the correct data to the model record when situations do apply" do
      form = described_class.new(intake, all_qualifiers_params)
      form.save
      intake.reload

      expect(intake.former_foster_youth).to eq "yes"
      expect(intake.homeless_youth).to eq "yes"
      expect(intake.not_full_time_student).to eq "yes"
      expect(intake.full_time_student_less_than_four_months).to eq "yes"
    end
  end
end