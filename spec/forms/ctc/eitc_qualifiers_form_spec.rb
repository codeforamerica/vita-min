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
    let(:qualifiers_params) do
      {
        former_foster_youth: "no",
        homeless_youth: "yes",
        not_full_time_student: "no",
        full_time_student_less_than_four_months: "yes"
      }
    end

    it "saves the data to the model" do
      form = described_class.new(intake, qualifiers_params)
      expect(form).to be_valid
      form.save
      intake.reload

      expect(intake.former_foster_youth).to eq "no"
      expect(intake.homeless_youth).to eq "yes"
      expect(intake.not_full_time_student).to eq "no"
      expect(intake.full_time_student_less_than_four_months).to eq "yes"
    end
  end
end
