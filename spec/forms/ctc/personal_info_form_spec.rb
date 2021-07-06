require "rails_helper"

describe Ctc::PersonalInfoForm do
  let(:intake) { build :ctc_intake }

  context "validations" do
    context "preferred name" do
      context "without preferred name param" do
        it "is not a valid form" do
          expect(described_class.new(intake, {})).not_to be_valid
        end
      end

      context "with preferred name param" do
        it "is a valid form" do
          expect(described_class.new(intake, { preferred_name: "Rose" })).to be_valid
        end
      end
    end
  end

  describe "#save" do
    context "when initializing intake is not a CtcIntake" do
      it "raises an error" do
        expect{
          described_class.new(build(:intake), {
              preferred_name: "Rose"
          }).save
        }.to raise_error StandardError, "Intake must be a type of Ctc Intake"
      end
    end

    it "creates a ctc intake, a ctc tax return for 2020, and an associated client object" do
      expect {
        described_class.new(intake, {
            preferred_name: "Rose",
        }).save
      }.to change(Intake::CtcIntake, :count).by(1)
       .and change(Client, :count).by(1)
       .and change(TaxReturn, :count).by(1)
    end
  end
end