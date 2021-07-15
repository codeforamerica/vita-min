require "rails_helper"

describe Ctc::IncomeForm do
  context "when the answer is no" do
    context "when intake is new" do
      let(:intake) { Intake::CtcIntake.new(visitor_id: "something") }
      it "creates the intake" do
        expect {
          described_class.new(intake, { had_reportable_income: "no" }).save
        }.to change(Intake, :count).by(1)
        expect(intake.reload.had_reportable_income).to eq "no"
      end
    end

    context "when intake is being updated" do
      let(:intake) { create :ctc_intake }

      it "updates the intake" do
        described_class.new(intake, { had_reportable_income: "no" }).save
        expect(intake.reload.had_reportable_income).to eq "no"
      end
    end
  end


  context "when the answer is yes" do
    let(:intake) { Intake::CtcIntake.new(visitor_id: "something") }
    context "when the intake hasnt been persisted yet" do
      it "does not create an intake" do
        expect {
          described_class.new(intake, { had_reportable_income: "yes" }).save
        }.to change(Intake, :count).by(0)
      end
    end

    context "when the intake has been persisted already" do
      let(:intake) { create :ctc_intake }

      it "updates the data onto the intake" do
        expect {
          described_class.new(intake, { had_reportable_income: "yes" }).save
        }.to change(intake.reload, :had_reportable_income).to("yes")
      end
    end
  end
end