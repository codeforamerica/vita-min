require "rails_helper"

RSpec.describe Questions::HadDependentsController do
  let(:had_dependents) { "unfilled" }
  let(:intake) { create :intake, had_dependents: had_dependents }
  before { sign_in intake.client }

  describe "#next_path" do
    context "when the user answers that they had dependents" do
      let(:had_dependents) { "yes" }

      it "returns the dependents path" do
        expect(subject.next_path).to eq dependents_path
      end
    end

    context "when the user didn't didn't have dependents" do
      let(:had_dependents) { "no" }

      it "returns the default next navigation path" do
        expect(subject.next_path).to eq dependent_care_questions_path
      end
    end
  end
end

