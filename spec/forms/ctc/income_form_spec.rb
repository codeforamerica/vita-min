require "rails_helper"

describe Ctc::IncomeForm do
  context "when the answer is no" do
    context "when intake is new" do
      let(:intake) { Intake::CtcIntake.new(visitor_id: "something") }
      it "does not create an intake" do
        expect(described_class.new(intake, { had_reportable_income: "no" }).had_reportable_income?).to eq false
      end
    end


  end


  context "when the answer is yes" do
    let(:intake) { Intake::CtcIntake.new(visitor_id: "something") }
    it "does not create an intake" do
      expect(described_class.new(intake, { had_reportable_income: "yes" }).had_reportable_income?).to eq true
    end
  end
end